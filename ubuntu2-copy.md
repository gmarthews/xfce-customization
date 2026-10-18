# Copying this setup to another XFCE machine (e.g. ubuntu2)

A reference procedure for replicating the whole desktop (panel, plank, hot corners, skippy-xd, rofi) onto a second machine over SSH. The example target is **ubuntu2** = `greg-BOHL-WXX9`, Ubuntu 26.04, XFCE 4.20 — but the steps generalize to any Debian/Ubuntu XFCE box.

> **Key differences from Fedora:** package manager is `apt` (not `dnf`); the panel dev package is `libxfce4panel-2.0-dev`; and Ubuntu uses a **multiarch** plugin dir, so the hot-corner `.so` must be moved after install.

---

## Prereqs / verify on the target

```sh
ssh ubuntu2
echo $XDG_SESSION_TYPE          # x11
pgrep -x xfce4-session && echo "session running"
pgrep -x xfwm4 && echo "wm running"
# GUI commands over SSH need the display:
export DISPLAY=:0
```

`sudo` needs a password on the target — batch the `apt` + `make install` prompts for the user.

---

## Phase 1 — transfer files (no sudo)

```sh
# patched hotcorner source
scp -r ~/Projects/xfce4-hotcorner-plugin ubuntu2:~/Projects/

# skippy-xd source (exclude build artifacts)
ssh ubuntu2 'mkdir -p ~/Projects'
rsync -az --exclude=build --exclude=.git ~/Projects/skippy-xd/ ubuntu2:~/Projects/skippy-xd/

# rofi theme
ssh ubuntu2 'mkdir -p ~/.config/rofi'
scp ~/.config/rofi/config.rasi ubuntu2:~/.config/rofi/config.rasi

# plank launchers
ssh ubuntu2 'mkdir -p ~/.config/plank/dock1/launchers'
scp ~/.config/plank/dock1/launchers/*.dockitem ubuntu2:~/.config/plank/dock1/launchers/

# skippy-xd config
ssh ubuntu2 'mkdir -p ~/.config/skippy-xd'
scp ~/.config/skippy-xd/skippy-xd.rc ubuntu2:~/.config/skippy-xd/skippy-xd.rc
```

---

## Phase 2 — install packages (sudo, on the target)

```sh
sudo apt update
sudo apt install -y \
  plank \
  libxfce4panel-2.0-dev libxfce4ui-2-dev libnotify-dev libwnck-3-dev libgtk-3-dev \
  libtool pkg-config intltool gettext autoconf automake \
  libx11-dev libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev \
  libxft-dev libxrender-dev libxinerama-dev libjpeg-dev libpng-dev zlib1g-dev \
  meson ninja-build \
  xdotool \
  feh
```

(`xdotool` for corner testing; `feh` for the skippy wallpaper fix.)

---

## Phase 3 — build + install hotcorner

```sh
cd ~/Projects/xfce4-hotcorner-plugin
./autogen.sh && ./configure --prefix=/usr && make -j$(nproc)
sudo make install

# Ubuntu multiarch fix — move the .so to the real plugin dir:
sudo mv /usr/lib/xfce4/panel/plugins/libhotcorner.so \
        /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/
```

> Always rebuild on the target — never copy Fedora-built `.so`/build artifacts.

## Phase 3b — build + install skippy-xd

```sh
cd ~/Projects/skippy-xd
meson setup build --prefix=/usr -Dskippy_gif=disabled -Dskippy_chipmunk=disabled
meson compile -C build
sudo meson install -C build
```

---

## Phase 4 — configure

### 4a. Dracula CSS
Append the Dracula block from [`gtk.css`](gtk.css) to `~/.config/gtk-3.0/gtk.css` (do **not** overwrite an existing rounded-panel block — merge).

### 4b. Plank
```sh
D=/net/launchpad/plank/docks/dock1/
gsettings set net.launchpad.plank.dock.settings:$D position 'left'
gsettings set net.launchpad.plank.dock.settings:$D hide-mode 'intelligent'
gsettings set net.launchpad.plank.dock.settings:$D show-dock-item-shadows false
```
Drop any copied `.dockitem` whose `.desktop` doesn't exist on the target, then add the rest via Plank's GUI (it's authoritative for dock items).

### 4c. Super → rofi
```sh
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>" -n -t string -s "rofi -show window"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/override" -t bool -s true
```

### 4d. Workspace names (if they drifted)
```sh
xfconf-query -c xfwm4 -p /general/workspace_names -t string -s "1" -t string -s "2"
```

### 4e. Add the hot-corner plugin
```sh
xfce4-panel --add=hotcorner
```
Then write the corner config to the new `~/.config/xfce4/panel/hotcorner-<N>.rc` (see `hotcorner.md`) and reload **both** the panel and the wrapper:
```sh
pkill -9 -x xfce4-panel; sleep 1; pkill -9 -x wrapper-2.0
```

### 4f. Variety wallpaper-pixmap fix
If the target runs **variety**, patch `~/.config/variety/scripts/set_wallpaper` to also run `feh --bg-fill "$WP"` (see `skippy-xd.md`), then run `feh --bg-fill <current-wallpaper>` once so `_XROOTPMAP_ID` is set.

---

## Phase 5 — verify (DISPLAY=:0)

```sh
export DISPLAY=:0
# corners
xdotool mousemove 4 4;    sleep 1; pgrep -x skippy-xd && echo "top-left fired"; pkill -x skippy-xd
xdotool mousemove 960 540; sleep 1
xdotool mousemove 1916 4;  sleep 1; pgrep -x rofi && echo "top-right fired"; pkill -x rofi
# CPU sanity (should be ~1%, not 76%)
pgrep -f wrapper-2.0 | xargs -I{} ps -o %cpu= -p {}
```

---

## Caveats

- **Don't disrupt the tasklist** — verify the window-buttons plugin is still present after `xfce4-panel --add=hotcorner`; if the add reused its slot, re-add tasklist.
- **The plugin runs in `wrapper-2.0`** — to reload a rebuilt `.so`, kill `xfce4-panel` **and** `wrapper-2.0`.
- **Don't install/copy xfdashboard** — the plugin's "Xfdashboard" combo option is a harmless no-op without it.
- If the target runs GNOME's indexer, mask `localsearch-3`/`tinysparql` (see `performance.md`).
