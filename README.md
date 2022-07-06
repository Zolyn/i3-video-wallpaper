# i3-video-wallpaper
Play dynamic wallpapers in i3wm (using XWinWrap and MPV).

## Features
- Support pausing the video when a window other than the desktop is focused
- Support multiple monitors
- Support playing multiple videos
- Generate, blur thumbnails, and set them as wallpaper (to fix some issue with Polybar and Picom)

## Dependencies
- xwinwrap-git (AUR)
- xdotool
- mpv

## Optional Dependencies
- ffmpeg (to generate thumbnail)
- feh (to set wallpaper)
- imagemagick (to blur the generated thumbnail)

## Usage
```bash
./setup.sh [OPTIONS] [VIDEO,BLUR_GEOMETRY,TIME_STAMP]
```
- VIDEO: Path to video.
- BLUR_GEOMETRY: Value which is passed to "convert -blur [value]". (Default: 16x16)
- TIME_STAMP: The time to generate the thumbnail. (Default: 00:00:01) 

## Examples
Always play `video.mp4` for **all** monitors.
```bash
./setup.sh -a video.mp4
```

Always play `video.mp4`, generate a thumbnail and set the **blurred** thumbnail as wallpaper for all monitors.
```bash
./setup.sh -anwb video.mp4
```

Always play `video.mp4` for **Monitor 1** and `video2.mp4` for **Monitor 2 and beyond**, set `BLUR_GEOMETRY` to `32x32` for the blurred thumbnail of `video2.mp4`, generate thumbnails and set the blurred thumbnails as wallpaper for the monitors.
```bash
./setup.sh -anwb video.mp4 video2.mp4,32x32
```
## Options
```
  -a: Always run video wallpaper.
  -n: Generate a thumbnail by using ffmpeg. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
  -w: Set the generated thumbnail as wallpaper by using feh. It may be useful if you use the built-in system tray of Polybar. (This can fix the background of system tray)
  -b: Blur the thumbnail. It may be useful if your compositor does not blur the background of the built-in system tray of Polybar.
  -f: Value which is passed to "feh --bg-[value]". Available options: center|fill|max|scale|tile (Default: fill)
  -d: Where the thumbnails is stored. (Default: $HOME/Pictures/i3-video-wallpaper)
  -h: Display this text.
```

## License
[MIT](https://mit-license.org)

## References
- [How to get an animated background on linux like mine and understanding PID files.](https://www.youtube.com/watch?v=b8rh9m3wOjk&list=PLRtT6Oib2tb2HrWb3gfUWdE4S21802mVF&index=1&t=901s)
