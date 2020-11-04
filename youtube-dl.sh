#!/bin/bash

# Set output path for music
music=~/storage/music

# Set output path for video
video=~/storage/movies

# Number of retry attempt
attempt=10

# Select default thumbnail for youtube music (in case failed to download cover)
thumb=https://www.xda-developers.com/files/2018/05/youtube-music-logo-1.png

# Color codes
ERR="\033[31m"
RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;34m"
PINK="\033[0;95m"
GREEN="\033[0;32m"
NORMAL="\033[0;39m"

# Innitialize URL if not provided in argument
clear
if [ -z "$1" ]; then
	echo -n -e "${BLUE}URL:${NORMAL} $url"
	read url
else
	url=$(echo $1|egrep -o 'https?://[^ ]+') # Extracting url from apps which shares a message instead of url
fi
clear

echo -e "${BLUE}URL:${NORMAL} $url"
echo ''
# Fetch title for file name
x=1
title=$(youtube-dl --get-title $url)
while [ -z "$title" ]
do
	if [ $x -eq $attempt ]; then
		echo -e "${ERR}ERROR:${NORMAL} Failed to fetch title. Using video ID."
		title=$(echo $url|sed 's/^.*v=//')
	else
		echo -e "${ERR}ERROR:${NORMAL} Title fetch unsuccessful. Retry attempt: $x"
		echo ''
		title=$(youtube-dl --get-title $url)
		x=$((x+1))
	fi
done

# Trimming conflicting characters
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
		cd "$music"
		echo -n -e "${RED}Youtube${NORMAL} URL Detected. Download ${GREEN}(a)${NORMAL}udio or ${GREEN}(v)${NORMAL}ideo: "
		read ytc
		echo ''
		case $ytc in
			a | A | audio | Audio | AUDIO | 1)

				# Fetch thumbnail off video
				y=1
				youtube-dl --write-thumbnail --skip-download -o 'temp/thumb_temp' $url
				while [ ! -f temp/thumb_temp.* ];
				do
					if [ $y -eq $attempt ]; then
						echo -e "${ERR}ERROR:${NORMAL} Fetching thumbnail failed. Using generic cover."
						curl $thumb --create-dirs --output 'temp/thumb_temp.png'
						echo ''
					else
						echo -e "${ERR}ERROR:${NORMAL} Thumbnail fetch unsuccessful. Retry attempt: $y"
						echo ''
						youtube-dl --write-thumbnail --skip-download -o 'temp/thumb_temp' $url
						y=$((y+1))
					fi
				done
				echo ''

				# Crop image in 1:1 ratio, remove black bar and repeat crop to 1:1 ratio
				# Done to remove some pesky logos which conflict with black bar detection
				DD=`identify -format "%[fx:min(w,h)]" temp/thumb_temp.*`
				convert 'temp/thumb_temp.*' -gravity center -crop ${DD}x${DD}+0+0 +repage 'temp/cover.jpg'
				mogrify -fuzz 10 -define trim:percent-background=0% -trim +repage 'temp/cover.jpg'
				DD=`identify -format "%[fx:min(w,h)]" temp/cover.jpg`
				convert 'temp/cover.jpg' -gravity center -crop ${DD}x${DD}+0+0 +repage 'temp/cover.jpg'

				# Fetch audio stream
				z=1
				youtube-dl -f 'bestaudio' --extract-audio --audio-format wav -o "temp/out.%(ext)s" $url
				while [ ! -f 'temp/out.wav' ];
				do
					if [ $z -eq $attempt ]; then
						echo -e "${ERR}ERROR:${NORMAL} Unable to download audio stream."
						rm -rf temp
						exit
					else
						echo -e "${ERR}ERROR:${NORMAL} Music stream fetch unsuccessful. Retry attempt: $z"
						echo ''
						youtube-dl -f 'bestaudio' --extract-audio --audio-format wav -o "temp/out.%(ext)s" $url
						z=$((z+1))
					fi
				done
				echo ''

				# Convert to mp3 and attach thumbnail
				ffmpeg -hide_banner -loglevel warning -stats -i 'temp/out.wav' -i 'temp/cover.jpg' -map 0:0 -map 1:0 -acodec libmp3lame -b:a 320K -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$title.mp3"

				# Removing temporary files
				rm -rf temp
				;;

			v | V | video | Video | VIDEO | 2)
				cd "$video"
				youtube-dl -f 'bestvideo+bestaudio/best' --merge-output-format mkv --write-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url
			;;
		esac
	;;

	s)
		cd "$music"
		echo -e "${YELLOW}SoundCloud${NORMAL} URL Detected."
		echo ''
		youtube-dl --embed-thumbnail -o '%(title)s.%(ext)s' $url
	;;

	o)
		cd "$video"
		echo -e "${PINK}Generic${NORMAL} URL Detected. Attempting download with youtube-dl."
		echo ''
		youtube-dl -f 'bestvideo+bestaudio/best' $url  -o "%(id)s.%(ext)s"
	;;
esac
