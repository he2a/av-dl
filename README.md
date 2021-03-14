# Youtube-DL Automation Script

Small script to download audio or video off youtube, soundcloud and other sites supported by youtube-dl. Made for use in WSL environment in Windows 10, but should work in any linux distro (including termux in android) without any problem. 

## Features
This script has two basic behaviours for different content.
- For video, downloads the best possible quality available and embeds subtitle if possible. 
- For audio, selectively downloads the best possible audio stream, crops the thumbnail to 1:1 ratio while trimming any black bars, then embeds it in V0 MP3 output.

## Requirement
- `youtube-dl` for downloading video/audio.
- `ffmpeg` for media conversion.

## Installation
Make sure you have [youtube-dl](https://github.com/ytdl-org/youtube-dl) and [ffmpeg](https://github.com/FFmpeg/FFmpeg) already installed and updated. Clone this repo using `git clone https://github.com/he2a/youtube-dl-automation-script youtube-dl-downloader`. Inside you will find `youtube-dl.sh` file. Run `chmod +x youtube-dl.sh` inside the directory to make it executable. Now, open the script using your text editor and change the download path to your choice and you are ready to use it.

## Settings
```
# Set output path for music.
music=~/storage/music

# Set output path for video.
video=~/storage/movies

# Number of retry attempts.
attempt=3

# Force default choice of download. Set to 'audio' for audio / 'video' for video / blank for manual choice.
defchoice=

# Set true to embed cover for audio download.
embedcover=true

# Set true to use thumbnail as cover for audio download or false to use default cover.
coverthumb=true

# Link to the cover image for use as default cover, including https:// part.
thumblink=

# Set true to autotrim cover to square for audio download.
autotrimthumb=true

# Set true to embed subtitles for video download.
embedsubs=true

# Set true to embed auto translated subtitles for youtube videos.
autosubs=true

# Set true to enable verbose mode mainly for debugging the script.
verbose=false
```
