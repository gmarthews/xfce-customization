#!/bin/sh
# XFCE rounded panel — apply panel config (see panel.md)

set -e

# 1. Compositor (Alt+Tab thumbnails)
xfconf-query -c xfwm4 -p /general/use_compositing -s true

# 2. Panel background — solid Dracula color
xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1
xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba \
  -t double -t double -t double -t double \
  -s 0.156860 -s 0.164710 -s 0.211760 -s 1.0

# 5. Plugin refinements
xfconf-query -c xfce4-panel -p /plugins/plugin-4/miniature-view -n -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-2/show-labels  -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-2/grouping      -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-2/show-handle   -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-11/digital-format -s " %a %d %b, %R "
xfconf-query -c xfce4-panel -p /plugins/plugin-6/square-icons -n -t bool -s true

echo "Done. Copy gtk.css into ~/.config/gtk-3.0/gtk.css and log out/in."
