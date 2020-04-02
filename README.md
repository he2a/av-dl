# Youtube-DL Automation Script
Small script to download audio or video off youtube/soundcloud/other using youtube-dl. Before using, change the $download path to your choice. Can be used in termux after changing the $download path to suitable path in android.
Pretty much downloads using standard youtube-dl commands for soundcloud audio or youtube video or other. For downloading audio off youtube, it centre crops the video thumbnail at 1:1 ratio and removes any black bar using ImageMagick to get a nice square album art. Feel free to experiment with the fuzziness to your liking. 
Requires ffmpeg, youtube-dl, python, imagemagick.
