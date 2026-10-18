# rofi — launcher + window switcher

Rofi does three jobs in this setup, all Dracula-themed:

| Mode | Command | Used for |
|------|---------|----------|
| `window` | `rofi -show window -window-thumbnail` | Alt+Tab-style window switcher (top-right corner) |
| `drun` | `rofi -show drun` | App launcher (bottom-right corner) |
| `run` | `rofi -show run` | Run arbitrary commands |

---

## Install

```sh
# Fedora
sudo dnf install rofi

# Ubuntu
sudo apt install rofi
```

## Dracula theme

Theme lives at `~/.config/rofi/config.rasi` (or a `*.rasi` in `~/.config/rofi/themes/`), using the Dracula palette (`#282a36` bg, `#bd93f9` accent, `#f8f8f2` fg). Copy the same file to any machine you want to match.

To switch modes on the fly:

```sh
rofi -show window -window-thumbnail   # window switcher (with thumbnails)
rofi -show drun                       # app launcher (needs a .desktop file)
rofi -show run                        # run any command
```

- `drun` lists only applications with a `.desktop` file.
- `run` executes the first token as a program (searched in `$PATH`) with the rest as arguments.

## Super key → rofi

Bind the bare `Super` key to the window switcher:

```sh
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>" -n -t string -s "rofi -show window"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/override" -t bool -s true
```

> Confirm bare `<Super>` isn't already bound before adding it (common to have `Super+A`, `Super+p`, etc. — those are fine, only a bare Super conflicts).

## Hot-corner integration

Rofi is launched by the hot-corner plugin's "custom command" action (`ACTION_ID=5`). See `hotcorner.md`:

- top-right → `rofi -show window`
- bottom-right → `rofi -show drun`
