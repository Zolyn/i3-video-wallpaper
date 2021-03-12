#!/bin/bash
video=none
alwaysRun=false
while getopts ":asp:" arg
do
    case "$arg" in
      "a")
        alwaysRun=true
        ;;
      "s")
        video=video
        ;;
      "p")
        echo $OPTARG
        video=$OPTARG
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      "*")
        echo "Unknown error while processing options"
        ;;
    esac
done
## kill and start video background
killall xwinwrap
while pgrep -u $UID -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --loop --pause -wid WID $video &
## logic for pausing and playing based on window focus and state
## alternative to --input-ipc-server is with xdotool to send p key
# xdotool key --window "$(xdotool search --class mpv)" p
if [ $alwaysRun == true ]; then
    echo "Done"
    sleep 1
    echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
else
    PLAY=false
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
fi
