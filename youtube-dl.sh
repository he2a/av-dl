#!/bin/bash
download='/mnt/d/Sandipan Mistry/Downloads' #set output path

red=`tput setaf 1` 
orange=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

if [ -z "$1" ]; then
	echo -n 'Enter URL: '
	read url
else
	url=$1
fi

cd "$download"
clear
echo "${magenta}"
echo "________________________________________________________________________________________________________________________"
echo " __   __        _        _             ___  _        _       _                  _   _            ___         _      _   "
echo " \ \ / /__ _  _| |_ _  _| |__  ___ ___|   \| |      /_\ _  _| |_ ___ _ __  __ _| |_(_)___ _ _   / __| __ _ _(_)_ __| |_ "
echo "  \ V / _ \ || |  _| || | '_ \/ -_)___| |) | |__   / _ \ || |  _/ _ \ '  \/ _\` |  _| / _ \ ' \  \__ \/ _| '_| | '_ \  _|"
echo "   |_|\___/\_,_|\__|\_,_|_.__/\___|   |___/|____| /_/ \_\_,_|\__\___/_|_|_\__,_|\__|_\___/_||_| |___/\__|_| |_| .__/\__|"
echo "                                                                                                              |_|       "
echo "________________________________________________________________________________________________________________________"
echo "${reset}"

echo -n 'URL: '
echo $url
echo -n 'Title: '
title=$( youtube-dl --get-title $url )
echo $title
title=$(echo "$title"|tr -d "'\`\"\\\/\|")
echo ''
if grep -q 'soundcloud' <<< "$url"; then
	flag='s'
elif grep -q 'youtube' <<< "$url"; then
	flag='y'
else
	flag='o'
fi

case $flag in
	s)
		echo "${orange}SoundCloud ${reset}URL Detected. Downloading audio: $title.mp3"
		echo ''
		youtube-dl --embed-thumbnail -o 'Music/%(title)s.%(ext)s' $url
	;;

	y)
		echo -n "${red}Youtube ${reset}URL Detected. Download Audio or Video: "
		read ytc
		echo ''

		case $ytc in
			a | A | audio | Audio | 1)
				echo "Downloading audio: $title.mp3"
				echo ''
				#thumbnail crop center 1:1
				youtube-dl --quiet --write-thumbnail --skip-download -o 'Music/thumb.jpg' $url
				DD=`identify -format "%[fx:min(w,h)]" Music/thumb.jpg`
				convert 'Music/thumb.jpg' -gravity center -crop ${DD}x${DD}+0+0 +repage 'Music/thumb.jpg'
				mogrify -fuzz 10% -define trim:percent-background=0% -trim +repage -format jpg 'Music/thumb.jpg'
				DD=`identify -format "%[fx:min(w,h)]" Music/thumb.jpg`
				convert 'Music/thumb.jpg' -gravity center -crop ${DD}x${DD}+0+0 +repage 'Music/thumb.jpg'
				
				#audio stream download
				youtube-dl -f 'bestaudio' --extract-audio --audio-format wav -o "Music/out.%(ext)s" $url
				
				#embedding thumbnail
				ffmpeg -i 'Music/out.wav' -i 'Music/thumb.jpg' -map 0:0 -map 1:0 -acodec libmp3lame -b:a 320K -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "Music/$title.mp3"
				
				#removing temp files
				rm 'Music/out.wav'
				rm 'Music/thumb.jpg'
			;;
			
			v | V | video | Video | 2)
				echo "Downloading video: $title.mkv"
				echo ''
				youtube-dl -f 'bestvideo[ext=webm]+bestaudio/bestvideo+bestaudio' --merge-output-format mkv --write-sub --sub-lang en --embed-subs -o 'Video/%(title)s.%(ext)s' $url
			;;
		esac
	;;

	o)
		echo "${cyan}Generic ${reset}URL Detected. Attempting download with youtube-dl:"
		echo ''
		youtube-dl -o 'Video/%(title)s.%(ext)s' $url
	;;
esac

