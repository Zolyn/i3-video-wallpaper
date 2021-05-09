#!/bin/bash
## kill and start video background
killall xwinwrap
while pgrep -u 1000 -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --loop -wid WID /home/zorin/Pictures/video/魔女之旅,伊蕾娜,咖啡.mp4 &
