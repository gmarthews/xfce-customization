# XFCE Customization

A complete XFCE desktop setup in the **Dracula** palette: a solid rounded panel, a left-edge Plank dock, hot-corner window overview (skippy-xd), a rofi launcher/window-switcher, and the performance fixes that keep it snappy.

Everything is documented as separate guides — pick the parts you want.

**Tested on:** Xfce 4.20 (xfce4-panel 4.20.7, xfwm4 4.20.0) on Fedora 44 and Ubuntu 26.04 (Xubuntu).

---

## Components

| Guide | What it does |
|-------|--------------|
| [panel.md](panel.md) | Rounded solid panel bar + Dracula Whisker menu / workspace switcher + Alt+Tab thumbnails |
| [plank.md](plank.md) | Left-edge dock, curated launchers, shadow-off, WM_CLASS matching gotcha |
| [hotcorner.md](hotcorner.md) | Corner-trigger plugin (built from source + patches) driving skippy-xd and rofi |
| [skippy-xd.md](skippy-xd.md) | Window overview (Exposé) + the wallpaper `_XROOTPMAP_ID` fix |
| [rofi.md](rofi.md) | Launcher + window switcher, Dracula theme, Super-key binding |
| [performance.md](performance.md) | CPU-leak fix, xfdashboard removal, GNOME indexer masking |
| [ubuntu2-copy.md](ubuntu2-copy.md) | Replicate the whole setup onto another XFCE machine over SSH |
| [media.md](media.md) | smplayer (mpv) as the default video player |

## Files

- [`gtk.css`](gtk.css) — the full panel + Dracula CSS block (`~/.config/gtk-3.0/gtk.css`)
- [`setup.sh`](setup.sh) — the panel xfconf commands in one script

## Quick start

```sh
# 1. Panel (see panel.md)
bash setup.sh
cp gtk.css ~/.config/gtk-3.0/gtk.css

# 2. Dock
sudo dnf install plank        # or: sudo apt install plank

# 3. Launcher + overview + corners (see hotcorner.md, skippy-xd.md, rofi.md)
sudo dnf install rofi
# …build + install the hot-corner plugin and skippy-xd from source…
```

Log out/in after the CSS change.

---

## Credits / origin

- **Hot-corner plugin** — `christopherkobayashi/xfce4-hotcorner-plugin`, with local patches (radius detection, skippy-xd action, CPU + crash fixes).
- **skippy-xd** — `richardgv/skippy-xd`.
- Palette: [Dracula](https://draculatheme.com) (`#282a36` / `#bd93f9` / `#f8f8f2`).
