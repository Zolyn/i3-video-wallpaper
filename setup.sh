#!/bin/bash
alwaysRun=false
video=''
needChmod=false
while getopts ":ap:h" arg
do
    case "$arg" in
      "a")
        alwaysRun=true
        ;;
      "p")
        video=$OPTARG
        ;;
      "h")
        cat << EOF
Options:
        -a: Always run video wallpaper.
        -p: Path to video.
        -h: Display this text.

EOF
        ;;
      ":")
        echo "ERROR: No argument value for option $OPTARG"
        ;;
      "?")
        echo "ERROR: Unknown option $OPTARG"
        ;;
      "*")
        echo "ERROR: Unknown error while processing options"
        ;;
    esac
done
generateScript() {
    if [ $alwaysRun == true ]; then
        cat > start.sh << EOF
#!/bin/bash
## kill and start video background
killall xwinwrap
while pgrep -u $UID -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --loop -wid WID ${video} &
EOF
        echo "INFO: Script was generated."
    else
        cat > start.sh << EOF
#!/bin/bash
## kill and start video background
killall xwinwrap
while pgrep -u $UID -x xwinwrap >/dev/null; do sleep 1; done
xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --pause --loop -wid WID ${video} &
PLAY=false
while true;
do 
    if [ "\$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ \$PLAY == false ]; then
            echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
            PLAY=true
    elif [ "\$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ \$PLAY == true ]; then
            echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
            PLAY=false
    fi
    sleep 1
done
EOF
        echo "INFO: Script was generated."
    fi
    if [ $needChmod == true ]; then
        chmod +x start.sh
    fi
    echo "Info: Completed."
}
if [ ! $video ]; then
    echo "ERROR: The video path is empty."
elif [ ! -f "start.sh" ]; then
    echo "INFO: It seems that the file start.sh does not exist."
    needChmod=true
    generateScript
else
    generateScript
fi