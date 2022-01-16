#!/bin/bash

# ---------------------------------------------------------------------------------
# A simple yt-dlp script for downloading songs or video off youtube and other sites
# ---------------------------------------------------------------------------------

# Set output path for music.
music="~/storage/music"

# Set output path for video.
video="~/storage/movies"

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
autosubs=false

# Set false to show a text instead of logo.
showlogo=true

# Set true to enable verbose mode mainly for debugging the script.
verbose=false

# ----------------------------------------------------------------------------

RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
NORMAL="\033[0;39m"
DEFIMG=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
WIDTHW=$(stty size | sed 's/.* //g')

function WARN () {
	if [ "$verbose" = true ]; then
		echo -e "${YELLOW}[ WARN ]${NORMAL} $1"
	fi
}

function INFO () {
	if [ "$verbose" = true ]; then
		echo -e "${BLUE}[ INFO ]${NORMAL} $1"
	fi
}

function ENDP () {
	if [ "$verbose" = true ]; then
		echo -ne "${RED}[ KILL ]${NORMAL} "
		read -n 1 -s -r -p "Script Terminated."
	fi
	exit
}

function ERRR () {
	if [ "$verbose" = true ]; then
		echo -e "${RED}[ KILL ]${NORMAL} $1"
	else
		echo -e "${RED}ERROR:${NORMAL} $1"
	fi
	ENDP
}

function SUCC () {
	if [ "$verbose" = true ]; then
		echo -e "${GREEN}[ SUCC ]${NORMAL} $1"
	fi
}

function CTXT () {
	echo -e "$1" | sed -e :a -e "s/^.\{1,$WIDTHW\}$/ & /;ta" | tr -d '\n' | head -c $WIDTHW
}

function checkchoicetwo () {
	case $1 in
		$2) return 1 ;;
		$3) return 1 ;;
		*) return 0 ;;
	esac
}

function loop () { 
	local i=1
	local j=$2
	
	while [ $i -le $j ]
	do
		$1
		if [ $? -eq 1 ];
		then
			return 1
			break
		else
			i=$((i+1))
		fi
	done
	return 0
}

function init-all () {
	checkchoicetwo $verbose "true" "false"
	if [ $? -eq 0 ]; then
		verbose=false
	fi
	
	INFO "Initializing script."
	
	if [ -z "$music" ] || [ -z "$video" ]; then
		ERRR "Default download directory not specified."
	fi
	
	if [ -z "$1" ]; then
		INFO "No URL detected."
	else
		url=$(echo $1|egrep -o 'https?://[^ ]+')
		if [ -z "$url" ]; then
			ERRR "Invalid URL."
		fi
	fi
	
	checkchoicetwo $defchoice "audio" "video"
	if [ $? -eq 1 ]; then
		cho=$defchoice
	else
		WARN "Invalid or no default choice of video detected."
		cho=n;
	fi
	
	checkchoicetwo $embedcover "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed cover image detected."
		embedcover=true
	fi
	
	checkchoicetwo $coverthumb "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of use thumbnail as cover detected."
		embedcover=true
	fi
	
	checkchoicetwo $autotrimthumb "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of auto trim thumbnail detected."
		embedcover=true
	fi
	
	checkchoicetwo $embedsubs "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed subtitles detected."
		embedcover=true
	fi
	
	checkchoicetwo $autosubs "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed auto generated subtitles detected."
		embedcover=true
	fi
	
	checkchoicetwo $showlogo "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of show logo detected."
		showlogo=true
	fi
	
	if [ -z "$(echo $thumblink|egrep -o 'https?://[^ ]+')" ]; then
		WARN "Invalid or no default thumbnail link detected."
		unset thumblink
	fi
	
	case $attempt in
		''|*[!0-9]*)
			WARN "Invalid value for attempt detected."
			attempt=1 
		;;
		*) 
			if [ $attempt -le 0 ]; then
				WARN "Invalid value for attempt detected."
				attempt=1
			fi
		;;
	esac
	SUCC "Initialization completed."
}

function logo () {
	if [ "$showlogo" = true ] && [ "$verbose" = false ]; then
		echo -ne "${RED}"
		CTXT "                     _ _ "
		CTXT "                    | | |"
		CTXT "  __ ___   ______ __| | |"
		CTXT " / _\ \ \ / /____/ _\ | |"
		CTXT "| (_| |\ V /    | (_| | |"
		CTXT " \__,_| \_/      \__,_|_|"
		echo -e " "
		echo -ne "${NORMAL}"
		CTXT "A simple audio/video downloader."
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
	else
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
		echo -ne "${RED}"
		CTXT "av-dl - A simple audio/video downloader."
		echo -ne "${NORMAL}"
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
	fi
}

function getTitle () {
	INFO "Fetching title of media."
	title=$(yt-dlp --get-title $url)
	if [ -z "$title" ]; then
		WARN "Title fetch failed."
		return 0
	else
		title=$(echo "$title"|tr -d "'\`\:\"\\\/\|")
		SUCC "Title fetch successful."
		return 1
	fi
}

function getAudio () {
	INFO "Fetching audio of media."
	yt-dlp --concurrent-fragments 8 -f 'bestaudio' --extract-audio --audio-format wav -o "temp_ytdl/audio.wav" $url
	if [ -f 'temp_ytdl/audio.wav' ]; then
		SUCC "Audio fetch successful."
		return 1
	else
		WARN "Audio fetch failed."
		return 0
	fi
}

function getCover () {
	INFO "Fetching album cover."
	curl $thumblink --create-dirs --output 'temp_ytdl/thumb_temp.tmp'
	if [ -f temp_ytdl/thumb_temp.tmp ]; then
		SUCC "Cover fetch successful."
		return 1
	else
		WARN "Cover fetch failed."
		return 0
	fi
}

function getThumb () {
	INFO "Fetching album cover."
	yt-dlp --write-thumbnail --skip-download -o 'temp_ytdl/thumb_temp' $url
	if [ -f temp_ytdl/thumb_temp.* ]; then
		SUCC "Cover fetch successful."
		return 1
	else
		WARN "Cover fetch failed."
		return 0
	fi
}

function defThumb () {
	mkdir -p temp_ytdl
	if [ -z "$thumblink" ]; then
		INFO "Writing embedded cover."
		base64 -d <<< "$DEFIMG" > temp_ytdl/thumb_temp.png
	else
		loop "getCover" $attempt
		if [ $? -eq 0 ]; then
			WARN "Default cover fetch failed. Using embedded cover."
			base64 -d <<< "$DEFIMG" > temp_ytdl/thumb_temp.png
		fi
	fi	
}

function trmThumb () {
	INFO "Cropping cover."
	mv temp_ytdl/thumb_temp.* temp_ytdl/thumb_raw
	ffmpeg -hide_banner -loglevel error -i 'temp_ytdl/thumb_raw' -vf "crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -q:v 2 'temp_ytdl/thumb001.jpg' 
	
	cp temp_ytdl/thumb001.jpg temp_ytdl/thumb002.jpg
	cp temp_ytdl/thumb001.jpg temp_ytdl/thumb003.jpg

	crop=$(ffmpeg -i 'temp_ytdl/thumb%3d.jpg' -vf "cropdetect=24:1:0" -f null - 2>&1 | egrep -o "crop=[^ ]+")
	ffmpeg -y -hide_banner -loglevel error -i 'temp_ytdl/thumb001.jpg' -vf "$crop,crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -q:v 2 'temp_ytdl/cover.jpg'
}

function jpgThumb () {
	INFO "Converting cover to jpeg."
	mv temp_ytdl/thumb_temp.* temp_ytdl/thumb_raw
	ffmpeg -y -hide_banner -loglevel error -i 'temp_ytdl/thumb_raw' -q:v 2 'temp_ytdl/cover.jpg'
}

# -----------------------------------------------------------------------------------------------

init-all $*
logo

if [ -z "$1" ]; then
	if [ "$verbose" = true ]; then
		echo -n -e "${BLUE}[ INFO ]${NORMAL} URL:"
	else
		echo -n -e "URL: "
	fi
	read url
	if [ -z "$(echo $url|egrep -o 'https?://[^ ]+')" ]; then
		ERRR "Invalid URL. Make sure to include the https:// part too."
	fi
else
	if [ "$verbose" = true ]; then
		echo -e "${BLUE}[ INFO ]${NORMAL} URL: $url"
	else
		echo -e "URL: $url"
	fi
fi

loop "getTitle" $attempt

if [ $? -eq 0 ]; then
	WARN "Title fetch failed. Using media ID from URL."
	title=$(echo $url|sed 's/^.*v=//')
fi

title=$(echo "$title"|tr -d "'\`\"\\\/\|")
if [ "$verbose" = true ]; then
	echo -e "${BLUE}[ INFO ]${NORMAL} Title: $title"
else
	echo -e "Title: $title"
	echo ''
fi

if [ "$cho" == "n" ]; then
	echo -n -e "Media type ${GREEN}(a)${NORMAL}udio or ${GREEN}(v)${NORMAL}ideo: "
	read cho
	echo ''
fi

case $cho in
	a | A | audio | Audio | AUDIO | 1)
		cd "$music"
		loop "getAudio" $attempt
		
		if [ $? -eq 0 ]; then
			ERRR "Audio fetch failed."
		fi
		
		if [ "$embedcover" = true ]; then
			if [ "$coverthumb" = true ]; then
				loop "getThumb" $attempt
				if [ $? -eq 0 ]; then
					WARN "Thumbnail fetch failed. Using default cover."
					defThumb
				fi
			else
				defThumb
			fi
			if [ "$autotrimthumb" = true ]; then
				trmThumb
			else
				jpgThumb
			fi
			INFO "Writing audio file."
			ffmpeg -hide_banner -loglevel error -stats -i 'temp_ytdl/audio.wav' -i 'temp_ytdl/cover.jpg' -map 0:0 -map 1:0 -acodec libmp3lame -q:a 0 -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$title.mp3"
		else
			INFO "Writing audio file."
			ffmpeg -hide_banner -loglevel error -stats -i 'temp_ytdl/audio.wav' -acodec libmp3lame -q:a 0 "$title.mp3"
		fi
		INFO "Deleting temporary files."
		rm -rf temp_ytdl
	;;

	v | V | video | Video | VIDEO | 2)
		cd "$video"
		if [ "$embedsubs" = true ]; then
			if [ "$autosubs" = true ]; then
				INFO "Writing video file."
				yt-dlp --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' --merge-output-format mkv --write-sub --write-auto-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url
			else
				INFO "Writing video file."
				yt-dlp --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' --merge-output-format mkv --write-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url
			fi
		else
			INFO "Writing video file."
			yt-dlp --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' --merge-output-format mkv -o "$title.%(ext)s" $url
		fi
	;;
	
	*)
		cd "$video"
		WARN "Invalid choice. Using generic settings."
		yt-dlp --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' --merge-output-format mkv -o "$title.%(ext)s" $url
	;;
esac