# Plank — the dock

A left-edge dock with `intelligent` auto-hide, a curated set of launchers, and shadows turned off (so it doesn't bleed into the skippy-xd overview — see `skippy-xd.md`).

**Tested on:** Fedora 44 (plank 0.11.89 from the `fedora` repo) and Ubuntu 26.04 (`apt install plank`).

---

## Install

```sh
# Fedora
sudo dnf install plank

# Ubuntu
sudo apt install plank
```

## Configure

Plank stores its settings in GSettings under `net.launchpad.plank.dock.settings`.

```sh
D=/net/launchpad/plank/docks/dock1/
gsettings set net.launchpad.plank.dock.settings:$D position 'left'
gsettings set net.launchpad.plank.dock.settings:$D hide-mode 'intelligent'
gsettings set net.launchpad.plank.dock.settings:$D auto-pinning false
gsettings set net.launchpad.plank.dock.settings:$D pinned-only false
```

> **Tip:** Plank treats its own GUI ("Plank Preferences", right-click → Preferences) as authoritative and may fight direct `gsettings` edits. For adding/removing items, the GUI is the reliable path.

## Shadows off

Plank's drop shadow was showing as a dark band along the screen edge inside skippy-xd. Disable it:

```sh
gsettings set net.launchpad.plank.dock.settings:$D show-dock-item-shadows false
# or right-click the dock → Preferences → "Show icon shadows" off
```

## Launchers

Each dock item is a `.dockitem` file in `~/.config/plank/dock1/launchers/`, pointing at a `.desktop` file:

```ini
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/vivaldi-stable.desktop
```

Copy a curated set of `.dockitem` files from one machine to another, but **drop any whose `.desktop` target doesn't exist** on the target machine (Plank will show a broken/blank icon for those).

### Gotcha — running app shows as a *second* icon

If clicking a pinned launcher spawns a **separate running-app icon** instead of reusing the pinned one, the launcher's `StartupWMClass` doesn't match the app's actual window class. Plank matches a running window to a launcher via `StartupWMClass` against the window's `WM_CLASS`.

**Diagnose** the real class:

```sh
wmctrl -lx | grep -i <app>
# e.g. 0x06c00004  0 vivaldi-stable.Vivaldi-stable  ...
```

**Fix** — set `StartupWMClass` to the window's instance (first token). Best done as a **user-level override** so it survives app updates:

```sh
mkdir -p ~/.local/share/applications
sed 's/^StartupWMClass=.*/StartupWMClass=<instance>/' \
  /usr/share/applications/<app>.desktop \
  > ~/.local/share/applications/<app>.desktop
# then point the .dockitem at the override:
#   Launcher=file:///home/<you>/.local/share/applications/<app>.desktop
# and restart plank
```

**Real example (Vivaldi):** the shipped desktop file had `StartupWMClass=vivaldi` but the window's `WM_CLASS` is `vivaldi-stable`/`Vivaldi-stable` — so a second icon appeared. Fixed by overriding `StartupWMClass=vivaldi-stable`.

## Autostart

Create `~/.config/autostart/plank.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
Hidden=false
```

(Or use XFCE "Session and Startup" → Application Autostart → Add → `plank`.)
