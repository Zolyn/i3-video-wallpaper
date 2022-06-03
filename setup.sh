#!/bin/bash
alwaysRun=false
video=''
generateThumbnail=false
setWallpaper=false
blur=false
blurGeometry='16x16'
fit="fill"
thumbnailStorePath="$HOME/Pictures/i3-video-wallpaper"
thumbnailPath=""
timeStamp='00:00:01'

PIDFILE="/var/run/user/$UID/vwp.pid"

declare -a PIDs

while getopts ":ap:nwbg:f:d:t:h" arg
do
    case "$arg" in
      "a")
        alwaysRun=true
        ;;
      "p")
        video=$OPTARG
        ;;
      "n")
        generateThumbnail=true
        ;;
      "w")
        setWallpaper=true
        ;;
      "b")
        blur=true
        ;;
      "g")
        blurGeometry=$OPTARG
        ;;
      "f")
        fit=$OPTARG
        ;;
      "d")
        thumbnailStorePath=$OPTARG
        ;;
      "t")
        timeStamp=$OPTARG
        ;;
      "h")
        cat << EOL
Options:
        -a: Always run video wallpaper.
        -p: Path to video.
        -n: Generate a thumbnail by using ffmpeg. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
        -w: Set the generated thumbnail as wallpaper by using feh. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
        -b: Blur the thumbnail. It may be useful if your compositor does not blur the background of the built-in system tray of Polybar.
        -g: Parameter which is passed to "convert -blur [parameter]". (Default: 16x16)
        -f: Parameter which is passed to "feh --bg-[paramater]". Available options: center|fill|max|scale|tile (Default: fill)
        -d: Where the thumbnails is stored. (Default: $HOME/Pictures/i3-video-wallpaper)
        -t: The time to generate the thumbnail. (Default: 00:00:01) 
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

kill_xwinwrap() {
  while read p; do
    [[ $(ps -p "$p" -o comm=) == "xwinwrap" ]] && kill -9 "$p";
  done < $PIDFILE
  sleep 0.5
}

play() {
  xwinwrap -ov -ni -g "$1" -- mpv --fs --loop-file --no-audio --no-osc --no-osd-bar -wid WID --no-input-default-bindings "$video" "$2" &
  PIDs+=($!)
}

run_always() {
  play "$1"
}

run() {
  PLAY=false
  play "$1" "--input-ipc-server=/tmp/mpvsocket --pause"
  while true;
  do
      if [ "$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ $PLAY == false ]; then
              echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
              PLAY=true
      elif [ "$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ $PLAY == true ]; then
              echo '{"command": ["cycle", "pause"]}' | socat - /tmp/mpvsocket
              PLAY=false
      fi
      sleep 0.5
  done
}

generate_thumbnail() {
  videoName="$(basename "$video" ".${video##*.}")"
  thumbnailPath="$thumbnailStorePath/$videoName.png"

  if [ ! -d "$thumbnailStorePath" ]; then
    mkdir -p "$thumbnailStorePath"
  fi

  ffmpeg -i "$video" -y -f image2 -ss "$timeStamp" -vframes 1 "$thumbnailPath"

  if [ $blur == true ]; then
    blurredThumbnailPath="$thumbnailStorePath/$videoName-blurred.png"
    convert "$thumbnailPath" -blur "$blurGeometry" "$blurredThumbnailPath"
    thumbnailPath=$blurredThumbnailPath
  fi
}

if [ ! -f "$video" ]; then
  echo "ERROR: The video path is empty."
  exit
fi

kill_xwinwrap

for g in $(xrandr -q | grep 'connected' | grep -oP '\d+x\d+\+\d+\+\d+'); do
  if [ $alwaysRun == true ]; then
    run_always "$g"
  else
    run "$g"
  fi
done

if [ $generateThumbnail == true ]; then
  generate_thumbnail
fi

if [ $setWallpaper == true ]; then
    feh "--bg-$fit" "$thumbnailPath"
fi

printf "%s\n" "${PIDs[@]}" > $PIDFILE

echo "Done."
