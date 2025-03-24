#!/bin/bash

# Temporary UI bugfix. Change delay if glitchy UI
# sleep 0.1

# ---------------------------------------------------------------------------------
# A simple yt-dlp script for downloading songs or video off youtube and other sites
# ---------------------------------------------------------------------------------

# Set output path for music. If blank, will set default location to ~/Music.
music=

# Set output path for video. If blank, will set default location to ~/Videos.
video=

# Number of retry attempts.
attempt=3

# Force default choice of download. Set to 'audio' for audio / 'video' for video / blank for manual choice.
defchoice=

# Set true to embed cover for audio download.
embedcover=true

# Set true to use thumbnail as cover for audio download or false to use default cover.
coverthumb=true

# Set true to autotrim youtube thumbnail to square for audio download.
autotrimthumb=true

# Set true to detect black bars in youtube thumbnail.
smartcrop=true

# Set true to embed subtitles for video download.
embedsubs=true

# Set true to embed auto translated subtitles for youtube videos.
autosubs=true

# Set false to show a text instead of logo.
showlogo=true

# Set true to speed up output but without fancy logo.
fastout=false

# Set true to enable verbose mode mainly for debugging the script.
verbose=false

# ----------------------------------------------------------------------------

RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
GREEN="\033[0;32m"
NORMAL="\033[0;39m"
WIDTHW=$(stty size | sed 's/.* //g')
DIRNAME="avdl_$RANDOM"

function CTXT {
	if [ $# -eq 0 ]; then
		return 1
	else
		if [ "$fastout" = false ] && [ $# -lt 3 ]; then
			local text=$(echo -e "$1" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')
		else
			local text=$1
		fi
		
		if [ -z "$3" ]; then
			local str_len="${#text}"
		else
			local str_len=$3
		fi
		
		if [ $str_len -ge $WIDTHW ]; then
			echo -e "$1"
			return 0
		elif [ $# -eq 1 ]; then
			local ch=" "
		else
			local ch="${2:0:1}"
		fi
	fi

	local filler_len="$(( (WIDTHW - str_len) / 2 ))"
	local filler_odd="$(( (WIDTHW - str_len) % 2 ))"
    local filler=""
	for (( i = 0; i < filler_len; i++ )); do
		filler="${filler}${ch}"
	done
	if [ $filler_odd -eq 0 ]; then
		echo -e "$filler$1$filler"
	else
		echo -e "$filler$ch$1$filler"
	fi
    return 0
}

function CLLN () {
	if [ "$verbose" = false ] || [ "$1" = true ]; then
		echo -ne "\r\033[K"
	else
		echo
	fi
}

function VBNL () {
	if [ "$verbose" = true ]; then
		if [ $# -eq 0 ] || [ "$1" = false ] ; then
			echo -ne "${CYAN}"
			CTXT "·" "·"
			echo -ne "${NORMAL}"
		elif [ "$1" = true ]; then
			CTXT "—" "—"
		fi
	elif [ "$1" = false ] && [ "$verbose" = false ]; then
		echo
	fi
}

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

function USER () {
	if [ "$verbose" = true ]; then
		echo -n -e "${PURPLE}[ USER ]${NORMAL} $1"
	else
		echo -n -e "$1"
	fi
}

function ENDP () {
	if [ "$verbose" = true ]; then
		echo -e "${RED}[ KILL ]${NORMAL} Script Terminated."
		echo -n -e "${BLUE}[ INFO ]${NORMAL} Press any key to continue…"
		read -n 1 -s -r
		CLLN true
	fi
	rm -rf ../$DIRNAME
	CTXT "—" "—"
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
	
	hash yt-dlp 2>/dev/null || ERRR "Dependency missing: yt-dlp not found."
	hash ffmpeg 2>/dev/null || ERRR "Dependency missing: ffmpeg not found."
	
	INFO "Colors available: ${RED}█${YELLOW}█${BLUE}█${PURPLE}█${CYAN}█${GREEN}█${NORMAL}█"
	INFO "Screen width: $WIDTHW"
	
	if [ $WIDTHW -le 65 ] && [ "$fastout" = false ]; then
		WARN "Screen width too low, switching to fast output."
		fastout=true
	fi
	
	INFO "Working folder name: ${GREEN}$DIRNAME${NORMAL}"
	
	if [ -z "$music" ] || [ ! -d "$music" ]; then
		WARN "Music directory either absent or not specified."
		INFO "Setting directory to ~/Music."
		music=~/Music
	fi
	
	if [ -z "$video" ] || [ ! -d "$video" ]; then
		WARN "Video directory either absent or not specified."
		INFO "Setting directory to ~/Videos."
		video=~/Videos
	fi
	
	if [ -z "$1" ]; then
		WARN "No URL detected."
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
	
	checkchoicetwo $smartcrop "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of smart crop detected."
		smartcrop=true
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
	
	checkchoicetwo $fastout "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of fast output detected."
		fastout=false
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
	
	if [ "$verbose" = true ]; then
		loglevel="info"
	else
		loglevel="fatal"
	fi
	
	SUCC "Initialization completed."
	VBNL true
}

function logo () {
	if [ "$showlogo" = true ] && [ "$verbose" = false ]; then
		echo -ne "\033]0;av-dl - A simple audio/video downloader\a"
		CTXT "—" "—" "1"
		if [ "$fastout" = false ]; then
			CTXT "${PURPLE}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⢤⣤⣤⣄⠀⠀⠀ ⠀ ⠀⠀⠀⠀⠀⠀                                    " " " "66"
			CTXT "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣶⣧⣐⠍⢙⣀⣼⣿⣿⣅⣤⣀⠀⠀⠀ ⠀⠀⠀                                     " " " "66"
			CTXT "${NORMAL}⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀${PURPLE}⠉⠙⠻⣿⣿⣿⣿⣿⣯⢆⣠⠀⠀⠀⠀⠀                                      " " " "66"
			CTXT "${NORMAL}⠀⠀⠀⠠⣶⠆⠀⢀⣺⡃⣀⠀⠀⠀${PURPLE}⠈⢿⣿⣿⣿⣿⡿⠏⠉⠀ ⠀⠀                                      " " " "66"
			CTXT "⠀⠀⣸⣷⣼⠆⠀${NORMAL}⡌⢹⣿⣿⠀⢄⠀⠀${PURPLE}⠈⣿⣿⣿⣿⡉⠉⠁⠀ ⠀⠀⠀                                     " " " "66"
			CTXT "⠀⢀⣿⣿⣿⠀${NORMAL}⠸⣷⣿⣿⣿⣆⣠⣿⡄⠀${PURPLE}⣼⣿⣿⣿⢆⣠⠀⠀⠀  ⠀                                     " " " "66"
			CTXT "⠀⢸⣿⣿⣿⠂⠀${NORMAL}⠹⡿⣿⣿⣿⣿⣿⠀⠀${PURPLE}⠟⠈⠏⠀⠀.⠀⠀ ⠀⠀⠀              •                      " " " "66"
			CTXT "⠀⣿⣿⣿⠏⢰⣿⣦⡀${NORMAL}⠚⠛⢿⣿⡿⠀⠀${PURPLE}⢸⠇⢀⠀⠀⠀⠀▪⠀⠀• ⣀    ▪·⣤${RED}▄▄${PURPLE}·${RED}  ▌ ▐${PURPLE}·    ⣀   ·${RED}▄▄▄▄  ▄▄▌   ${PURPLE}" " " "66"
			CTXT "⢠⢿⣿⣿⠀⢾⣿⣿⡇⢻⡏⠀⠀⠀⠀⠀⡆⢰⣿⣿⡗⢠⣿⣿⣷⣤⣀▪ ⣀·   ⢸${RED}█ ▀█ ${PURPLE}·${RED}█${PURPLE}·${RED}█▌        ██${PURPLE}·${RED} ██ ██${PURPLE}·${RED}   ${PURPLE}" " " "66"
			CTXT "⠀⠀⠈⠙⠒⠿⠿⣿⣿⠸⠇⠀⠀⠀⠀⠀⣷⠘⣿⠟⣠⣿⣿⣿⣷⢆⣠ ▪·⠀•  ⣼${RED}█▀▀█ ▐█▐█${PURPLE}·${RED}  ▄██${PURPLE}·${RED}  ▐█${PURPLE}·${RED} ▐█▌██${PURPLE}·${RED}   ${PURPLE}" " " "66"
			CTXT "⠀⠀⠀⠀⠀⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀⣿⠀⣃⣾⣿⣿⣿⠏⠉•⠀·• ⠉ ⣀·⢸${RED}█ ${PURPLE}·${RED}▐▌ ███         ██${PURPLE}·${RED} ██ ▐█▌▐▌ ${PURPLE}" " " "66"
			CTXT "⠀⠀⠀⠀⠀⠀⠀⠀⠸⠻⠀⠀⠀⠀⠀⠀⢄⣸⣿⣿⣿⣿⣭⣭⡉⠉⠁· .⠀⠀• ⣀${RED}▌  ▀ ${PURPLE}·${RED} ▀     ${PURPLE}·${RED}    ▀▀▀▀▀${PURPLE}·${RED} ${PURPLE}·${RED}▀▀▀  " " " "66"
			echo -e "${NORMAL}"
			CTXT "A simple ${GREEN}(a)${NORMAL}udio/${GREEN}(v)${NORMAL}ideo downloader."
			fastout=true
		else
			echo -ne "${RED}"
			CTXT "                     _ _ "
			CTXT "                    | | |"
			CTXT "  __ ___   ______ __| | |"
			CTXT " / _\ \ \ / /____/ _\ | |"
			CTXT "| (_| |\ V /    | (_| | |"
			CTXT " \__,_| \_/      \__,_|_|"
			echo
			echo -ne "${YELLOW}"
			CTXT "A simple audio/video downloader."
			echo -ne "${NORMAL}"
		fi
		CTXT "—" "—"
	else
		CTXT "—" "—"
		echo -ne "\033]0;av-dl - A simple audio/video downloader\a"
		CTXT "${RED}av-dl${NORMAL} : A simple ${GREEN}(a)${NORMAL}udio/${GREEN}(v)${NORMAL}ideo downloader"
		CTXT "—" "—"
		fastout=true
	fi
}

function getTitle () {
	INFO "Fetching title of media."
	title=$(yt-dlp --get-title $url)
	if [ -z "$title" ]; then
		WARN "Title fetch failed."
		return 0
	else
		SUCC "Title fetch successful."
		return 1
	fi
}

function getAudio () {
	INFO "Fetching audio of media."
	VBNL false
	yt-dlp --concurrent-fragments 8 -f 'bestaudio' --extract-audio --audio-format wav -o "./audio.wav" $url
	VBNL
	if [ -f './audio.wav' ]; then
		SUCC "Audio fetch successful."
		return 1
	else
		WARN "Audio fetch failed."
		return 0
	fi
}

function getThumb () {
	INFO "Fetching album cover."
	VBNL false
	yt-dlp --write-thumbnail --skip-download -o './thumb_temp' $url
	VBNL
	if [ -f ./thumb_temp.* ]; then
		SUCC "Cover fetch successful."
		return 1
	else
		WARN "Cover fetch failed."
		return 0
	fi
}

function defThumb () {
	INFO "Generating cover art."
	VBNL false
	local xc=$((750 + RANDOM % 2501))
	local yc=$((2000 + (RANDOM % 2 * 2 - 1) * $(awk -v xc="$xc" 'BEGIN {print int(sqrt(1250^2 - (xc - 2000)^2))}')))
	local xd=$((4000 - xc))
	local yd=$((4000 - yc))
	local gradient="gradients=s=4000x4000:c0=0x33517e:c1=0x645098:c2=0xa53f97:c3=0xdf1177:c4=0xff033e:c5=0x2f4858:n=5:y0=$yc:x0=$xc:y1=$yd:x1=$xd:t=linear,format=rgba"
	ffmpeg -y -hide_banner -loglevel $loglevel -stats -f lavfi -i "color=c=0x20292FFF:s=4000x4000,format=rgba" -filter_complex "geq=r='32':g='41':b='47':a='255*(1-between(hypot(X-2000,Y-2000),0,1150))'" -frames:v 1 -update 1 './a.png'
	ffmpeg -y -hide_banner -loglevel $loglevel -stats -f lavfi -i $gradient -filter_complex "geq=g='g(X,Y)':a='255*between(hypot(X-2000,Y-2000),0,1200)',deband,noise=c0s=6:c0f=u" -frames:v 1 -update 1 './b.png'
	ffmpeg -y -hide_banner -loglevel $loglevel -stats -f lavfi -i "color=c=0x20292FFF:s=4000x4000,format=rgba" -vf "geq=a='255*max(lte((X-2000+(530/3)+25)+sqrt(3)*abs(Y-2000),530)*gte(X-2000+(530/3)+25,0),between(hypot(X-2000,Y-2000),570,630))':r='255*max(lte((X-2000+(530/3)+25)+sqrt(3)*abs(Y-2000),530)*gte(X-2000+(530/3)+25,0),between(hypot(X-2000,Y-2000),570,630))':g='255*max(lte((X-2000+(530/3)+25)+sqrt(3)*abs(Y-2000),530)*gte(X-2000+(530/3)+25,0),between(hypot(X-2000,Y-2000),570,630))':b='255*max(lte((X-2000+(530/3)+25)+sqrt(3)*abs(Y-2000),530)*gte(X-2000+(530/3)+25,0),between(hypot(X-2000,Y-2000),570,630))'" -frames:v 1 -update 1 './c.png'
	ffmpeg -y -hide_banner -loglevel $loglevel -stats -i './a.png' -i './b.png' -i './c.png' -filter_complex "[0][1]overlay=format=auto,format=rgba[tmp];[tmp][2]overlay=format=auto,format=rgba,scale=1000:1000:flags=lanczos,format=rgb24" -frames:v 1 -update 1 './thumb_temp.png'
	VBNL
	if [ -f ./thumb_temp.png ]; then
		SUCC "Cover generation successful."
		return 1
	else
		WARN "Cover generation failed."
		return 0
	fi

}

function savThumb () {
	local filepath=$(find "./" -type f -name "thumb_temp.*" | head -n 1)
	if [[ -n "$filepath" ]]; then
        INFO "Detected file extension as ${filepath##*.}."
    else
		ERRR "Cover art not detected."
	fi
	
	if [ "$autotrimthumb" = true ] && [ "$coverthumb" = true ]; then
		INFO "Cropping cover."
		VBNL false
		ffmpeg -y -hide_banner -loglevel $loglevel -stats -i $filepath -vf "crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -frames:v 1 -update 1 './cover.png'
		if [ "$smartcrop" = true ]; then
			mv ./cover.png ./thumb001.png
			cp ./thumb001.png ./thumb002.png
			cp ./thumb001.png ./thumb003.png
			local crop=$(ffmpeg -i './thumb%03d.png' -vf "cropdetect=14:1:0" -f null - 2>&1 | egrep -o "crop=[^ ]+")
			ffmpeg -y -hide_banner -loglevel $loglevel -stats -i './thumb001.png' -vf "$crop,crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -frames:v 1 -update 1 './cover.png'
		fi
		VBNL
		if [ -f ./cover.png ]; then
			SUCC "Cover crop successful."
			return 1
		else
			WARN "Cover crop failed."
			return 0
		fi
	elif [ "${filepath##*.}" != "png" ]; then
		INFO "Converting cover to png."
		VBNL false
		ffmpeg -y -hide_banner -loglevel $loglevel -stats -i $filepath -frames:v 1 -update 1 './cover.png'
		VBNL
		if [ -f ./cover.png ]; then
			SUCC "Cover conversion successful."
			return 1
		else
			WARN "Cover conversion failed."
			return 0
		fi
	elif [ "${filepath##*.}" == "png" ]; then
		INFO "File extension already png, skipping conversion."
		mv ./thumb_temp.png ./cover.png
	else
		ERRR "Unknown error occured while processing coverart."
	fi
}

# -----------------------------------------------------------------------------------------------

if [ "$verbose" = true ]; then
	logo
	init-all $*
else
	init-all $*
	logo
fi

if [ -z "$1" ]; then
	USER "${GREEN}URL:${NORMAL} "
	read url
	if [ -z "$(echo $url|egrep -o 'https?://[^ ]+')" ]; then
		ERRR "Invalid URL. Make sure to include the https:// part too."
	fi
else
	USER "${GREEN}URL:${NORMAL} $url"
	echo
fi

loop "getTitle" $attempt

if [ $? -eq 0 ]; then
	WARN "Title fetch failed. Using media ID from URL."
	title=$(echo $url|sed 's/^.*v=//')
fi
title=$(echo "$title"|tr -d "'\?\`\"\\\/\|")

USER "${GREEN}Title:${NORMAL} $title"
echo

if [ "$cho" == "n" ]; then
	USER "Media type ${GREEN}(a)${NORMAL}udio or ${GREEN}(v)${NORMAL}ideo: "
	read -n1 cho
	CLLN
	VBNL true
fi

case $cho in
	a | A | audio | 1)
		USER "User choice detected as ${GREEN}(a)${NORMAL}udio."
		echo
		INFO "Creating temporary folder ${GREEN}$DIRNAME${NORMAL}"
		mkdir -p "$music/$DIRNAME"
		cd "$music/$DIRNAME"
		
		loop "getAudio" $attempt
		
		if [ $? -eq 0 ]; then
			ERRR "Audio fetch failed."
		fi
		
		if [ "$embedcover" = true ]; then
			if [ "$coverthumb" = true ]; then
				loop "getThumb" $attempt
				if [ $? -eq 0 ]; then
					WARN "Thumbnail fetch failed."
					defThumb
				fi
			else
				defThumb
			fi
			savThumb
			INFO "Writing audio file."
			VBNL false
			ffmpeg -y -hide_banner -loglevel $loglevel -stats -i './audio.wav' -i './cover.png' -map 0:0 -map 1:0 -acodec libmp3lame -q:a 0 -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$title.mp3"
			VBNL false
		else
			INFO "Writing audio file."
			VBNL false
			ffmpeg -y -hide_banner -loglevel $loglevel -stats -i './audio.wav' -acodec libmp3lame -q:a 0 "$title.mp3"
			VBNL false
		fi
		mv -f ./*.mp3 ..
		USER "Successfully downloaded audio file ${GREEN}$title.mp3${NORMAL}."
		echo
	;;

	v | V | video | 2)
		USER "User choice detected as ${GREEN}(v)${NORMAL}ideo."
		echo
		INFO "Creating temporary folder ${GREEN}$DIRNAME${NORMAL}"
		
		mkdir -p "$video/$DIRNAME"
		cd "$video/$DIRNAME"
		
		if [ "$embedsubs" = true ]; then
			if [ "$autosubs" = true ]; then
				INFO "Writing video file."
				VBNL false
				yt-dlp --concurrent-fragments 8 -f 'bestvideo*+bestaudio/best' --embed-chapters --sponsorblock-mark "sponsor,preview,filler,music_offtopic" --merge-output-format mkv --write-sub --write-auto-sub --sub-langs en.*  --sub-format "ass/srt/best" --convert-subs srt --embed-subs --embed-metadata -o "./$title.%(ext)s" $url
				VBNL false
			else
				INFO "Writing video file."
				VBNL false
				yt-dlp --concurrent-fragments 8 -f 'bestvideo*+bestaudio/best' --embed-chapters --sponsorblock-mark "sponsor,preview,filler,music_offtopic"  --merge-output-format mkv --write-sub --sub-lang en.* --sub-format "ass/srt/best" --convert-subs srt --embed-subs --embed-metadata -o "./$title.%(ext)s" $url
				VBNL false
			fi
		else
			INFO "Writing video file."
			VBNL false
			yt-dlp --concurrent-fragments 8 -f 'bestvideo*+bestaudio/best' --embed-chapters --sponsorblock-mark "sponsor,preview,filler,music_offtopic"  --merge-output-format mkv -o "./$title.%(ext)s" $url
			VBNL false
		fi
		mv -f ./*.mkv ..
		USER "Successfully downloaded video file ${GREEN}$title.mkv${NORMAL}."
		echo
	;;
	
	*)
		WARN "No known action for user input: ${RED}$cho${NORMAL}."
		ENDP "Invalid choice."
	;;
esac
ENDP