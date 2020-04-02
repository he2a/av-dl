# Youtube-DL Automation Script

## Usage
Small script to download audio or video off youtube/soundcloud/other sites supported by youtube-dl. Before using, set the `$download` path to your choice. 

This script was made for use in WSL2 environment in windows and not tested in actual linux. For using in termux, modify the download path to android equivalent, save the file as `termux-url-opener` in `~/bin/` and then make it executable using `chmod +x termux-url-opener`.

## Basic Overview
Pretty much downloads from any video sites supported by youtube-dl. More documentation on site supported is available at the official <a href="https://ytdl-org.github.io/youtube-dl/index.html">youtube-dl repo.</a>

For youtube video, it downloads the highest quality video possible and embeds the subtitle file. 
For downloading audio off youtube video, it centre crops the video thumbnail at 1:1 ratio and removes any black bar to get a nice pseudo  album art. 
For SoundCloud, it downloads the audio file and embeds song cover art.

## Requirement
* `python` for use in youtube-dl.
* `youtube-dl` for downloading video/audio.
* `imagemagick` for audio cover art creation.
