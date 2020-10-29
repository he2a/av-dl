#!/bin/bash

clear
if [ -z "$1" ]; then
	echo -n 'Enter URL: '
	read url
else
	url=$(echo $1|egrep -o 'https?://[^ ]+') # Extracting url from apps which shares a message instead of url
fi
clear

# Color codes
ERR="\033[31m"
RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;34m"
PINK="\033[0;95m"
GREEN="\033[0;32m"
NORMAL="\033[0;39m"

download=~/storage # Set output path
cd "$download"

echo -e "${BLUE}URL:${NORMAL} $url"			
x=1
title=$(youtube-dl --get-title $url)
while [ -z "$title" ]
do
	echo -e "${ERR}ERROR:${NORMAL} Title fetch unsuccessful. Retry attempt: $x"
	echo ''
	title=$(youtube-dl --get-title $url)
	x=$((x+1))
	if [ $x -eq 11 ]; then
		echo -e "${ERR}ERROR:${NORMAL} Failed to fetch title. Using video ID."
		title=$(echo $url|sed 's/^.*v=//')
	fi
done
title=$(echo "$title"|tr -d "'\`\"\\\/\|")
echo -e "${BLUE}Title:${NORMAL} $title"
echo ''

if grep -q 'soundcloud' <<< "$url"; then
	flag='s'
elif grep -q 'youtu' <<< "$url"; then
	flag='y'
else
	flag='o'
fi

case $flag in
	y)
		echo -n -e "${RED}Youtube${NORMAL} URL Detected. Download ${GREEN}(a)${NORMAL}udio or ${GREEN}(v)${NORMAL}ideo: "
		read ytc
		echo ''
		case $ytc in
			a | A | audio | Audio | AUDIO | 1)				
				y=1
				youtube-dl --write-thumbnail --skip-download -o 'music/thumb_temp' $url
				while [ ! -f music/thumb_temp* ];
				do
					echo -e "${ERR}ERROR:${NORMAL} Thumbnail fetch unsuccessful. Retry attempt: $y"
					echo ''
					youtube-dl --write-thumbnail --skip-download -o 'music/thumb_temp' $url
					y=$((y+1))
					if [ $y -eq 11 ]; then
						echo -e "${ERR}ERROR:${NORMAL} Fetching thumbnail failed. Downloading generic cover."
						curl https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?ixid=eyJhcHBfaWQiOjEyMDd9 --output 'music/thumb_temp.jpg'
						echo ''
					fi
				done
				echo ''
				
				convert 'music/thumb_temp*' 'music/cover.jpg' >/dev/null
				DD=`identify -format "%[fx:min(w,h)]" music/cover.jpg`
				convert 'music/cover.jpg' -gravity center -crop ${DD}x${DD}+0+0 +repage 'music/cover.jpg'
				mogrify -fuzz 10% -define trim:percent-background=0% -trim +repage 'music/cover.jpg'
				DD=`identify -format "%[fx:min(w,h)]" music/cover.jpg`
				convert 'music/cover.jpg' -gravity center -crop ${DD}x${DD}+0+0 +repage 'music/cover.jpg'
				
				z=1
				youtube-dl -f 'bestaudio' --extract-audio --audio-format wav -o "music/out.%(ext)s" $url
				while [ ! -f 'music/out.wav' ];
				do
					echo -e "${ERR}ERROR:${NORMAL} Music stream fetch unsuccessful. Retry attempt: $z"
					echo ''
					youtube-dl -f 'bestaudio' --extract-audio --audio-format wav -o "music/out.%(ext)s" $url
					z=$((z+1))
					if [ $z -eq 11 ]; then
						echo -e "${ERR}ERROR:${NORMAL} Unable to download audio stream."
						rm music/cover.jpg
						rm music/thumb_temp*
						exit
					fi
				done
				echo ''
				
				ffmpeg -hide_banner -loglevel warning -stats -i 'music/out.wav' -i 'music/cover.jpg' -map 0:0 -map 1:0 -acodec libmp3lame -b:a 320K -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "music/$title.mp3"


				rm music/out.wav
				rm music/cover.jpg
				rm music/thumb_temp*
				;;

			v | V | video | Video | VIDEO | 2)
				youtube-dl -f 'bestvideo+bestaudio/best' --merge-output-format mkv --write-sub --sub-lang en --embed-subs -o "movies/$title.mkv" $url
			;;
		esac
	;;	
	
	s)
		echo -e "${YELLOW}SoundCloud${NORMAL} URL Detected."
		echo ''
		youtube-dl --embed-thumbnail -o 'music/%(title)s.%(ext)s' $url
	;;

	o)
		echo -e "${PINK}Generic${NORMAL} URL Detected. Attempting download with youtube-dl."
		echo ''
		youtube-dl -f 'bestvideo+bestaudio/best' $url  -o "movies/%(id)s.%(ext)s"
	;;
esac