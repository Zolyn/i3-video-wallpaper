#!/bin/bash
alwaysRun=false
generateThumbnail=false
setWallpaper=false
blur=false
fit='fill'
thumbnailStorePath="$HOME/Pictures/i3-video-wallpaper"

isPlaying=false

PIDFILE="/var/run/user/$UID/vwp.pid"

declare -a PIDs
declare -a Monitors
declare -a ThumbnailList
declare -a ParsedValueList
declare -a IndexMap=(
  [0]="video"
  [1]="blurGeometry"
  [2]="timeStamp"
)

while getopts ":anwbf:d:h" arg; do
  case "$arg" in
  "a")
    alwaysRun=true
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
  "f")
    fit=$OPTARG
    ;;
  "d")
    thumbnailStorePath=$OPTARG
    ;;
  "h")
    cat <<EOL
Usage:
./setup.sh [OPTIONS] [VIDEO,BLUR_GEOMETRY,TIME_STAMP]

Example:
./setup.sh -anwb video.mp4 video2.mp4,32x32

NOTE: The path of the video(s) must be the last parameter!

Options:
    -a: Always run video wallpaper.
    -n: Generate a thumbnail by using ffmpeg. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
    -w: Set the generated thumbnail as wallpaper by using feh. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
    -b: Blur the thumbnail. It may be useful if your compositor does not blur the background of the built-in system tray of Polybar.
    -f: Value which is passed to "feh --bg-[value]". Available options: center|fill|max|scale|tile (Default: fill)
    -d: Where the thumbnails is stored. (Default: $HOME/Pictures/i3-video-wallpaper)
    -h: Display this text.

EOL
    exit
    ;;
  ":")
    echo "ERROR: Option $OPTARG requires argument(s)"
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

# Remove options
shift $((OPTIND - 1))

kill_xwinwrap() {
  while read p; do
    [[ $(ps -p "$p" -o comm=) == "xwinwrap" ]] && kill -9 "$p"
  done <$PIDFILE
  sleep 0.5
}

play_video() {
  if [ $alwaysRun == true ]; then
    xwinwrap -ov -ni -g "$1" -- mpv --fs --loop-file --no-audio --no-osc --no-osd-bar -wid WID --no-input-default-bindings "$2" &
  else
    xwinwrap -ov -ni -g "$1" -- mpv --fs --loop-file --input-ipc-server="/tmp/mpvsocket$3" --pause --no-audio --no-osc --no-osd-bar -wid WID --no-input-default-bindings "$2" &
  fi
  PIDs+=($!)
}

pause_video() {
  for ((i = 1; i <= ${#Monitors[@]}; i++)); do
    echo '{"command": ["cycle", "pause"]}' | socat - "/tmp/mpvsocket$i"
  done
}

check_if_file_exists() {
  local path=$1

  if [ -f "$path" ];then
    echo "true"
  else
    echo "false"
  fi
}

generate_thumbnail_if_not_exists() {
  local video=$1
  local timeStamp=$2
  local thumbnailPath=$3

  if [ "$(check_if_file_exists "$thumbnailPath")" == false ];then
    ffmpeg -i "$video" -y -f image2 -ss "$timeStamp" -vframes 1 "$thumbnailPath"
  fi
}

generate_thumbnail_main() {
  local video=$1
  local timeStamp=$2
  local blurGeometry=$3

  local videoName
  videoName="$(basename "$video" ".${video##*.}")"
  local thumbnail="$thumbnailStorePath/$videoName"
  local thumbnailPath="$thumbnail.png"
  local blurredThumbnailPath="$thumbnail-blurred-$blurGeometry.png"

  if [ ! -d "$thumbnailStorePath" ]; then
    mkdir -p "$thumbnailStorePath"
  fi

  if [ $blur == true ]; then
    if [ "$(check_if_file_exists "$blurredThumbnailPath")" == false ];then
      generate_thumbnail_if_not_exists "$video" "$timeStamp" "$thumbnailPath"
      convert "$thumbnailPath" -blur "$blurGeometry" "$blurredThumbnailPath"
    fi
    thumbnailPath=$blurredThumbnailPath
  else
    generate_thumbnail_if_not_exists "$video" "$timeStamp" "$thumbnailPath"
  fi

  ThumbnailList+=("$thumbnailPath")
}

generate_all_thumbnail() {
  for p in "${ParsedValueList[@]}"; do
    declare -a ParsedValue
    local video=''
    local blurGeometry=''
    local timeStamp=''

    readarray -d , -t ParsedValue <<<"$p"

    for ((i = 0; i < ${#IndexMap[@]}; i++)); do
      eval "${IndexMap[$i]}=${ParsedValue[$i]}"
    done

    generate_thumbnail_main "$video" "$timeStamp" "$blurGeometry"
  done
}

check_if_video_exists() {
  local videoPath=$1

  if [ "$(check_if_file_exists "$videoPath")" == false ];then
    echo "ERROR: The video path $videoPath is empty."
    exit
  fi
}

trim() {
  echo "$1" | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}

parse_and_play() {
  declare -a ValueArr
  local video=''
  local blurGeometry='16x16'
  local timeStamp='00:00:01'
  local geometry=$2
  local monitorIndex=$3

  readarray -d , -t ValueArr <<<"$1"

  for ((i = 0; i < ${#ValueArr[@]}; i++)); do
    ValueArr[$i]=$(trim "${ValueArr[$i]}")
  done

  for ((i = 0; i < ${#IndexMap[@]}; i++)); do
    if [ -n "${ValueArr[$i]}" ]; then
      eval "${IndexMap[$i]}=${ValueArr[$i]}"
    fi
  done

  check_if_video_exists "$video"

  play_video "$geometry" "$video" "$monitorIndex"

  ParsedValueList+=("$video,$blurGeometry,$timeStamp")
}

main() {
  for g in $(xrandr -q | grep 'connected' | grep -oP '\d+x\d+\+\d+\+\d+'); do
    Monitors+=("$g")
    local value
    value=$(eval echo "\$${#Monitors[@]}")

    if [ -z "$value" ]; then
      value=$(eval echo "\$$#")
    fi

    parse_and_play "$value" "$g" "${#Monitors[@]}"
  done

  printf "%s\n" "${PIDs[@]}" >$PIDFILE

  if [ $generateThumbnail == true ]; then
    generate_all_thumbnail
  fi

  if [ $setWallpaper == true ]; then
    feh "--bg-$fit" "${ThumbnailList[@]}"
  fi

  if [ $alwaysRun != true ]; then
    while true; do
      if [ "$(xdotool getwindowfocus getwindowname)" == "i3" ] && [ $isPlaying == false ]; then
        pause_video
        isPlaying=true
      elif [ "$(xdotool getwindowfocus getwindowname)" != "i3" ] && [ $isPlaying == true ]; then
        pause_video
        isPlaying=false
      fi
      sleep 0.5
    done
  fi
}

if [ -z "$*" ]; then
  echo "ERROR: Requires video path"
  exit
fi

kill_xwinwrap
main "$@"
