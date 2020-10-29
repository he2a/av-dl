# Youtube-DL Automation Script

Small script to download audio or video off youtube, soundcloud and other sites supported by youtube-dl. Made for use in WSL1 environment in Windows 10, but should work in any linux distro (including termux in android) without any problem. 

## Features
This script has four basic behaviours for different content.
- For youtube video, downloads the best possible quality for video and embeds subtitle if available. 
- For youtube audio, selectively downloads the best possible audio stream, crops the thumbnail to 1:1 ratio while trimming any black bars, then embeds it in 320k mp3 output.
- For soundcloud songs, downloads the audio file and embeds the cover art. 
- For other sites default behaviour is to download best possible quality.

## Requirement
- `youtube-dl` for downloading video/audio.
- `ffmpeg` for media conversion.
- `imagemagick` for cover art creation.

## Installation
Make sure you have [youtube-dl](https://github.com/ytdl-org/youtube-dl), [ffmpeg](https://github.com/FFmpeg/FFmpeg) and [imagemagick](https://github.com/ImageMagick/ImageMagick) already installed and updated. 
Clone this repo using `git clone https://github.com/he2a/youtube-dl-automation-script youtube-dl-downloader`. Inside you will find `youtube-dl.sh` file. Run `chmod +x youtube-dl.sh` inside the directory to make it executable. 
Now, open the script using your text editor and change the download path to your choice and you are ready to use it.
