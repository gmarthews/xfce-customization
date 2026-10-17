# XFCE Rounded Panel

A single, solid, rounded XFCE panel bar in the Dracula palette, with live Alt+Tab window thumbnails.

**Result:**

- One solid rounded bar — no "sections" or gaps between plugins
- Alt+Tab shows live window thumbnails
- Workspace switcher as clean named buttons
- Dracula palette (`#282a36` = `rgb(40,42,54)`)

**Tested on:** Xfce 4.20 (xfce4-panel 4.20.7, xfwm4 4.20.0) on Fedora 44 and Xubuntu.

---

## The two gotchas (read first)

These two mistakes are what actually cause the "segmented panel" and "corners not rounded" problems most people hit.

### 1. `background-style=none` + a semi-transparent color = visible "sections"

The panel's own background and the *external* plugins (Whisker menu, system tray, PulseAudio, power manager, notifications) are drawn by two different pieces of code. External plugins live in their own `GtkPlug` windows (named `#XfcePanelWindowWrapper`).

- With `background-style=none`, each wrapper falls back to the theme's opaque background.
- With a semi-transparent panel color (alpha < 1), the wrapper stacks that alpha again, so each plugin renders *darker* than the panel.

**Fix:** `background-style=color` **and** a fully opaque color (alpha `1.0`). The wrapper then injects the same solid color on every widget, unifying the whole bar.

### 2. Rounded corners on the wrong selector = square plugins + transparent notches

`.xfce4-panel { border-radius: … }` matches **both** the panel window *and* every wrapper window (they all carry the `xfce4-panel` class). Rounding them carves transparent corners into each plugin.

**Fix:** round **only** the panel window with its unique class `.panel-1`, and force wrappers square:

```css
.panel-1 { border-radius: 12px; }
#XfcePanelWindowWrapper { border-radius: 0; }
```

---

## Steps

### 1. Enable the xfwm4 compositor (for Alt+Tab thumbnails)

Live Alt+Tab thumbnails require xfwm4's own compositor — picom does not provide them.

```sh
xfconf-query -c xfwm4 -p /general/use_compositing -s true
```

If picom is running, disable it (kill it and disable its autostart):

```sh
pkill picom
# set Hidden=true in ~/.config/autostart/picom.desktop
```

### 2. Panel background — solid color

```sh
xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1
xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba \
  -t double -t double -t double -t double \
  -s 0.156860 -s 0.164710 -s 0.211760 -s 1.0
```

(`0.156860 0.164710 0.211760` = `rgb(40,42,54)` = Dracula `#282a36`, alpha `1.0`.)

### 3. gtk.css — rounded corners

Copy [`gtk.css`](gtk.css) into `~/.config/gtk-3.0/gtk.css` (or append its panel block). The essential lines:

```css
.panel-1 { border-radius: 12px; }
#XfcePanelWindowWrapper { border-radius: 0; }
.xfce4-panel button { background-color: transparent; }
```

Apply by logging out/in — `xfce4-panel -r` does not reliably reload CSS.

### 4. Transparent separators at both ends

The leftmost/rightmost plugins sit flush against the panel edge, and their opaque windows cover the rounded corners. Add a **transparent separator** at each end (Panel Preferences → Items → add Separator, set it transparent) so the rounding shows through.

### 5. Plugin refinements (optional, for the clean look)

Workspace switcher as buttons (not miniature):

```sh
xfconf-query -c xfce4-panel -p /plugins/plugin-4/miniature-view -n -t bool -s false
```

Window buttons — no labels, no grouping, no handles:

```sh
xfconf-query -c xfce4-panel -p /plugins/plugin-2/show-labels  -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-2/grouping      -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-2/show-handle   -t bool -s false
```

Clock — padding via leading/trailing spaces in the format:

```sh
xfconf-query -c xfce4-panel -p /plugins/plugin-11/digital-format -s " %a %d %b, %R "
```

Notification area — square icons:

```sh
xfconf-query -c xfce4-panel -p /plugins/plugin-6/square-icons -n -t bool -s true
```

> **Note:** plugin IDs (`plugin-2`, `plugin-4`, …) are per-install. Confirm yours with:
> `xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids`

---

## Notes / reference

- `background-style` values: `0` = none, `1` = color, `2` = image.
- Panel window classes: `panel`, `xfce4-panel`, `background`, `panel-1`; wrapper windows are named `#XfcePanelWindowWrapper`.
- On X11, CSS `margin` cannot float the panel (the panel sets its own position).
- Free-floating the panel (`position` `p=0`) breaks autohide — the reveal strip follows the floating position instead of the screen edge.
- Workspace margins (Settings → Workspaces → Margins) should stay `0` — a docked panel reserves its own space.

## Files

- [`gtk.css`](gtk.css) — the panel CSS block
- [`setup.sh`](setup.sh) — all xfconf commands in one script
