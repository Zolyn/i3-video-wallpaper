#!/bin/bash
alwaysRun=false
video=''
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
        cat << EOL
Options:
        -a: Always run video wallpaper.
        -p: Path to video.
        -h: Display this text.

EOL
        ;;
      ":")
        echo "ERROR: No argument value for option $OPTARG"
        exit
        ;;
      "?")
        echo "ERROR: Unknown option $OPTARG"
        exit
        ;;
      "*")
        echo "ERROR: Unknown error while processing options"
        exit
        ;;
    esac
done

run_always() {
  ## kill and start video background
  killall xwinwrap
  sleep 1
  xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --loop -wid WID "$video" &
}

run() {
  PLAY=false
  # ## kill and start video background
  killall xwinwrap
  sleep 1
  xwinwrap -fs -fdt -ni -b -nf -ov -- mpv --input-ipc-server=/tmp/mpvsocket --no-audio --pause --loop -wid WID "$video" &
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
}

if [ ! -f "$video" ]; then
  echo "ERROR: The video path is empty."
  exit
fi

if [ $alwaysRun == true ]; then
  run_always
else
  run
fi
