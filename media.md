# Media — smplayer (mpv) as the default video player

VLC 3.x deadlocks on software-decoded HEVC/x265 on this hardware (i7-8550U + Intel/NVIDIA hybrid): the video freezes mid-play and the whole UI hangs (play/quit buttons stop responding). **smplayer** (using **mpv** as its backend) handles the same files reliably.

## Switch

```sh
# kill a hung VLC
pkill -x vlc

# set smplayer as the default for every video/* mime type
xdg-mime default smplayer.desktop video/*
```

This writes a user-level `~/.config/mimeapps.list`, so it persists and Nemo/Thunar open video files with smplayer.

Verify a few:

```sh
xdg-mime query default video/mp4    # smplayer.desktop
xdg-mime query default video/x-matroska
```

> smplayer uses mpv (not mplayer) as its engine here; mpv's software HEVC decode is efficient enough for 1080p.
