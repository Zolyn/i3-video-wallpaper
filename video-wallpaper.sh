!/bin/bash
## kill and start video background
killall xwinwrap
while pgrep -u $UID -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --loop --pause -wid WID ~/Video\ Wallpapers/Anime-Himiko-Toga-Particles-Live-Wallpaper.mp4 &

## logic for pausing and playing based on window focus and state
## alternative to --input-ipc-server is with xdotool to send p key
# xdotool key --window "$(xdotool search --class mpv)" p

PLAY=false
sleep 1

while true; do 
        if [ "$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ $PLAY == false  ]; then
                echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
                PLAY=true
        elif [ "$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ $PLAY == true ]; then
                echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
                PLAY=false
        fi
        sleep 1
done
