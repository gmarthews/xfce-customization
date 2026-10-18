# skippy-xd — window overview (Exposé)

A lightweight fullscreen "show all windows" overview, triggered from the top-left hot corner. Stateless: `skippy-xd` with no arguments does a one-shot Exposé and exits (no daemon), which is exactly how the hot-corner plugin invokes it.

**Source:** `richardgv/skippy-xd`. Local copy: `~/Projects/skippy-xd`.

---

## Build

skippy-xd uses **Meson** (not autotools). Disable the unneeded `gif` and `chipmunk` (physics) features — they pull in extra deps and aren't used for the plain overview grid:

```sh
cd ~/Projects/skippy-xd
meson setup build --prefix=/usr -Dskippy_gif=disabled -Dskippy_chipmunk=disabled
meson compile -C build
sudo meson install -C build
```

Installs `skippy-xd` → `/usr/bin/skippy-xd` (+ config + man page).

## Usage

```sh
skippy-xd            # one-shot overview (used by the hot corner)
```

(There is also `--expose` mode, but that needs a persistent daemon — the no-arg form is the right one for a stateless corner trigger.)

## The wallpaper fix (no black background)

**Symptom:** the overview renders **black** with a ghost/shadow of whatever was on screen.

**Cause:** skippy-xd grabs the desktop wallpaper via the root-window property `_XROOTPMAP_ID`. On a system where **variety** (or similar) sets the wallpaper only through `xfconf`, that property is left as `None`, so skippy gets nothing and paints black.

**Fix:** make the wallpaper setter also paint the root pixmap with `feh`, which sets `_XROOTPMAP_ID` (and `ESETROOT_PMAP_ID`).

1. Confirm the property is `None`:

   ```sh
   xprop -root _XROOTPMAP_ID
   # _XROOTPMAP_ID:  not found.  (or 0x0)
   ```

2. Patch variety's `~/.config/variety/scripts/set_wallpaper` — in the XFCE branch, after it sets the wallpaper, add:

   ```sh
   feh --bg-fill "$WP"
   ```

3. Apply immediately (once):

   ```sh
   feh --bg-fill "$(xfconf-query -c xfdesktop -p /backdrop/screen0/monitor0/workspace0/last-image)"
   ```

   Verify:

   ```sh
   xprop -root _XROOTPMAP_ID   # now a real pixmap id (e.g. 0x8c00001)
   ```

> **Note:** the "black ghost" was the dead giveaway that skippy was compositing over an un-painted root window.

## Config

`~/.config/skippy-xd/skippy-xd.rc` (or `/etc/xdg/skippy-xd.rc` for the system default). This setup uses a **dimmed-wallpaper** background and **hides the dock**:

```
[general]
background = dimmed
showAllDesktops = true
pollingInterval = 1
border = 1

[xinerama]
showAll = true

[bindings]
miwMouse1 = "exec"
miwMouse2 = "focus"
miwMouse3 = "iconify"
```

## Plank interaction

Plank's drop shadow leaked into the overview as a dark edge band. Turn plank shadows off (see `plank.md`) so the overview is clean.
