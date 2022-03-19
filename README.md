# i3-video-wallpaper

requires xwinwrap-git from AUR, xdotool, mpv

support pausing the video when a window other than the desktop is focused

## Basic Usage
```bash
./setup.sh [-a] [-p video.mp4] [-n] [-w] [-b] [-g 16x16] [-f center] [-d $HOME/Pictures/i3-video-wallpaper] [-t 00:00:01] [-h]
```
## Parameters
```
$ ./setup.sh -h
Options:
        -a: Always run video wallpaper.
        -p: Path to video.
        -n: Generate a thumbnail by using ffmpeg. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
        -w: Set the generated thumbnail as wallpaper by using feh. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
        -b: Blur the thumbnail. It may be useful if your compositor does not blur the background of the built-in system tray of Polybar.
        -g: Parameter which is passed to "convert -blur [parameter]". (Default: 16x16)
        -f: Parameter which is passed to "feh --bg-[paramater]". Available options: center|fill|max|scale|tile (Default: center)
        -d: Where the thumbnails is stored. (Default: $HOME/Pictures/i3-video-wallpaper)
        -t: The time to generate the thumbnail. (Default: 00:00:01) 
        -h: Display this text.
```

## License
[MIT](https://mit-license.org)
