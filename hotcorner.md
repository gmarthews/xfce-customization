# Hot-corner plugin

A third-party XFCE panel plugin that triggers an action when the pointer hits a screen corner. In this setup it drives **skippy-xd** (top-left) and **rofi** (top-right, bottom-right).

The plugin is built **from source** (with local patches) — it is not in the Fedora/Ubuntu repos.

**Source:** `christopherkobayashi/xfce4-hotcorner-plugin` (updated for XFCE 4.20). Local copy: `~/Projects/xfce4-hotcorner-plugin`.

---

## Build dependencies

Fedora:

```sh
sudo dnf install xfce4-panel-devel libxfce4ui-devel libnotify-devel libtool pkg-config meson
```

Ubuntu:

```sh
sudo apt install libxfce4panel-2.0-dev libxfce4ui-2-dev libnotify-dev libwnck-3-dev libgtk-3-dev \
  libtool pkg-config intltool gettext autoconf automake meson ninja-build
```

> **Ubuntu note:** the dev package is `libxfce4panel-2.0-dev`, **not** `xfce4-panel-dev`.

## Build + install

```sh
cd ~/Projects/xfce4-hotcorner-plugin
./autogen.sh && ./configure --prefix=/usr && make -j$(nproc)
sudo make install
```

- Fedora installs to `/usr/lib64/xfce4/panel/plugins/libhotcorner.so`.
- **Ubuntu multiarch:** `configure` can't detect the multiarch `plugindir` (the pkg-config var is absent), so `sudo make install` drops the `.so` in the wrong place — move it:

  ```sh
  sudo mv /usr/lib/xfce4/panel/plugins/libhotcorner.so \
          /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/
  ```

## Patches applied to the source

These fixes make the plugin actually usable and stable (the stock version has real bugs):

1. **Corner radius** — `src/util.c`: `CORNER_RADIUS 8`. The stock detection is a single exact pixel (`x==0 && y==0`), which is nearly impossible to hit. This turns each corner into an 8×8 px zone.
2. **skippy-xd action** — `src/util.h` + `src/util.c`: `start_skippy_xd()` runs `system("skippy-xd")` (no-arg, one-shot Exposé).
3. **Action switch** — `src/hotcorner.c`: `case 6: return start_skippy_xd;`.
4. **Dropdown entry** — `src/hotcorner.c`: append "Skippy-XD" to the corner action combo-box.
5. **Hidden icon** — `src/hotcorner.c`: `gtk_widget_set_no_show_all(icon, TRUE); gtk_widget_hide(icon);` (the "video-display" icon is useless).
6. **WnckHandle reuse (CPU fix)** — `src/hotcorner.h` + `src/hotcorner.c`: create the `WnckHandle` **once and reuse it**. The stock code called `wnck_handle_new()` on every 50 ms poll and leaked it — that caused ~76% CPU and climbing memory.
7. **`run_command()` NULL guard** — `src/util.c`: guard against `strlen(NULL)` when a custom-command corner has no command text (this was a null-pointer crash).
8. **Fullscreen-check NULL guard** — `src/hotcorner.c`: guard before `wnck_window_is_fullscreen()` (another crash source).

## Configure

The plugin writes per-instance config to `~/.config/xfce4/panel/hotcorner-<N>.rc` (`<N>` = its panel plugin id). Action IDs:

| ID | Action |
|----|--------|
| 0 | None |
| 5 | Run custom command (`UPPER_*_COMMAND`) |
| 6 | skippy-xd |

This setup:

```ini
UPPER_LEFT_ACTION_ID=6
UPPER_RIGHT_ACTION_ID=5
UPPER_RIGHT_COMMAND=rofi -show window
LOWER_LEFT_ACTION_ID=0
LOWER_RIGHT_ACTION_ID=5
LOWER_RIGHT_COMMAND=rofi -show drun
DISABLE_WHEN_FULL_SCREEN=1
```

So: **top-left = skippy-xd**, **top-right = rofi window switcher**, **bottom-right = rofi app launcher (drun)**, bottom-left unused.

## Add to the panel + reload

```sh
xfce4-panel --add=hotcorner
```

> **Critical:** the plugin runs in a separate `wrapper-2.0` process. After editing the `.rc` **or** installing a rebuilt `.so`, you must kill **both** the panel and the wrapper so the plugin re-reads its config / reloads the new binary (editing the file alone gets overwritten on logout by the running plugin's stale in-memory state):

```sh
pkill -9 -x xfce4-panel; sleep 1; pkill -9 -x wrapper-2.0
```

## Verify

```sh
xdotool mousemove 4 4;    sleep 1; pgrep -x skippy-xd && echo "top-left fired"
xdotool mousemove 960 540  # reset to center first (the plugin shares a single
                           # isExecuted flag across corners)
xdotool mousemove 1916 4;  sleep 1; pgrep -x rofi && echo "top-right fired"
```

> The plugin fires only once per "enter corner → leave to center → enter corner" cycle; jump the pointer back to the screen center between tests or the second corner won't trigger.
