#!/bin/bash
## kill and start video background
killall xwinwrap
while pgrep -u 1000 -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --pause --loop -wid WID /home/zorin/Pictures/video/灵梦2.mp4 &
PLAY=false
while true;
do 
    if [ "$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ $PLAY == false ]; then
            echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
            PLAY=true
    elif [ "$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ $PLAY == true ]; then
            echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
            PLAY=false
    fi
    sleep 1
done
