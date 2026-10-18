# Performance + cleanup

Three things made this desktop fast and stopped it stuttering / hanging on shutdown:

1. Fixing a CPU/memory leak in the hot-corner plugin.
2. Removing an unwanted auto-starting app (`xfdashboard`).
3. Masking GNOME's file-indexer (a background CPU hog).

---

## 1. Hot-corner plugin CPU/memory leak

**Symptom:** the `wrapper-2.0` process pegged at ~76% CPU and memory climbing (178 MB+ and growing). The desktop felt like it was "almost crashing" — but it was just CPU saturation, no hardware fault.

**Cause:** the plugin called `wnck_handle_new()` on every 50 ms mouse poll and never freed it, leaking a handle each tick.

**Fix:** create the `WnckHandle` once and reuse it (see `hotcorner.md`, patch #6). After rebuild + reload:

| Metric | Before | After |
|---|---|---|
| `wrapper-2.0` CPU | ~76–87% | **~1%** |
| RSS | 178 MB | **~51 MB** |

The ~1% that remains is the normal 50 ms poll loop.

---

## 2. Remove xfdashboard

`xfdashboard` (a GNOME-style overview) was auto-starting even though it wasn't in the autostart list.

**Cause:** it was being restored by **`xfce4-session` session restore** (the running process carried `--sm-client-id …`), not by an autostart entry.

**The trap:** removing the autostart entry or `pkill`-ing it does **not** stick — on the next logout, `xfce4-session` re-saves the entry from its in-memory session list, so it "comes back" even after `dnf remove` leaves the binary gone (the entry stays as a harmless ghost, but it also respawns until the binary is actually gone).

**Clean removal:**

```sh
# 1. delete any autostart entry
rm -f ~/.config/autostart/xfdashboard-daemon.desktop

# 2. remove the binary (the restart command then fails silently and it stays gone)
sudo dnf remove -y xfdashboard        # Fedora
# sudo apt remove -y xfdashboard      # Ubuntu

# 3. strip it from the saved session cache (optional, cosmetic)
#    ~/.cache/sessions/xfce4-session-<host>:0 — remove the xfdashboard Client block
```

> Don't bother hand-editing the session cache expecting it to survive logout — `xfce4-session` re-saves its own list. Removing the binary is the thing that actually kills it.

## 3. Mask GNOME's `localsearch` / `tinysparql` indexer

**Symptom:** `localsearch-3` and `localsearch-extractor-3` (GNOME's file-search indexer, successor to `tracker`) spiked to ~98% CPU.

**Fix:** mask them (user-level, survives reboots and desktop environments):

```sh
systemctl --user mask \
  localsearch-3.service \
  localsearch-control-3.service \
  localsearch-writeback-3.service \
  tinysparql-xdg-portal-3.service
pkill -f localsearch
```

This only affects GNOME's full-text file search. Nemo's own search is unaffected.
