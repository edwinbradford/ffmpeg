#!/bin/bash

# Echo current directory
echo; pwd; echo

# Script title
echo "This script uses FFmpeg to encode and package media for streaming as MPEG-DASH and HLS streams."; echo;

# Check if FFmpeg exists
echo "Checking for FFmpeg..."; echo;
if command -v ffmpeg >/dev/null 2>&1 ; then
  echo "FFmpeg is installed."; echo;
else
  echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
  read -n 1 -s -r -p "Press any key to exit... ";
  exit 1;
fi

# Check if Basic Calculator exists
if command -v bc >/dev/null 2>&1 ; then
  echo "Basic Calculator is installed."; echo;
else
  echo >&2 "This script requires the POSIX standard Basic Calculator (bc). Please add it to your shell"; echo;
  read -n 1 -s -r -p "Press any key to exit... ";
  exit 1;
fi

# Source media
echo "Drag and drop the folder containing the media into this window and press enter..."; echo;

# Disable case sensitivity and error reporting for missing file types
shopt -s nullglob
shopt -s nocaseglob

# Check for supported media files
while :; do
  # Assign selected directory path to variable
  IFS="" read -r input
  echo

  # Evaluate path variable for quotes and spaces for cd command
  eval "input=( $input )"

  # Use wslpath to convert Windows paths to Unix paths for WSL on Windows
  if command -v wslpath >/dev/null 2>&1; then
    input="$( wslpath "$input" )"
  fi

  # Change directory to selected directory
  cd "${input}"

  if [[ -n $(echo *.{avi,mkv,mov,mp4,mxf}) ]]; then
    echo "The following supported media files were found... "; echo;
    ls -l *.{avi,mkv,mov,mp4,mxf}; echo; break
  else
    echo "No supported media files found. Please try again... "; echo; continue
  fi

done

# Reset shell options
# shopt -u nullglob
# shopt -u nocaseglob

# Regex for validating numbers
isNumeral='^[0-9]+([.][0-9]+)?$'

# Framerate
while :; do
  read -ep "Please enter the framerate... " framerate
  echo
  [[ $framerate =~ $isNumeral ]] || { echo; echo "The framerate must be a number. Please try again... "; echo; continue; }
  break
done

# Fragment size, see http://anton.lindstrom.io/gop-size-calculator/
while :; do
  read -ep "Please enter the keyframe interval (secs)... " fragment
  echo
  [[ $fragment =~ $isNumeral ]] || { echo "The keyframe interval must be a number only. Please try again... "; echo; continue; }
  break
done

# Stream segment length, multiple of fragment size
while :; do
  read -ep "Please enter the segment length ( ${fragment} × integer number )... " segment
  echo
  [[ $segment =~ $isNumeral ]] || { echo "The segment length must be a number. Please try again... "; echo; continue; }
  break
done

# Calculate the GOP with basic calculaotr for floating point values
GOP=$(echo "$framerate*$fragment" | bc)

# List all files with supported video formats
echo "Your media will be encoded at ${framerate} fps with a GOP size of ${GOP} frames and a segment length of ${segment} s... "
echo

# Pause for input
read -n 1 -s -r -p "Press any key to continue... "
echo

# Make directories

if [ ! -d "logs" ]; then
  mkdir "logs";
fi

if [ -d "media" ]; then
  echo; echo "The existing 'media' folder in your directory will be deleted."; echo;
  while true; do
    read -p "Delete? [y] / [n] " yn
    case $yn in
      [Yy]* ) rm -rf "media"; break;;
      [Nn]* ) exit 0;;
      * ) echo; echo "Please enter 'y' for yes or 'n' for no... " ; echo;;
    esac
  done
fi

mkdir "media";
mkdir "media/chunks";
mkdir "media/inits";

CHUNKNAME=chunks/stream-\$RepresentationID\$-\$Bandwidth\$-\$Number%05d\$.m4s
INITNAME=inits/stream-\$RepresentationID\$-\$Bandwidth\$.m4s

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  ffmpeg \
  -channel_layout stereo \
  -i "$i" \
  -map 0:v:0 \
  -map 0:v:0 \
  -map 0:v:0 \
  -map 0:v:0 \
  -map 0:a:0 \
  -r $framerate \
  -preset slow \
  -vstats_file logs/ffmp4.log \
  -c:a aac \
  -profile:a aac_low \
  -ar 48000 \
  -ac 2 \
  -b:a:0 160k \
  -metadata:s:a language=eng \
  -c:v libx264 \
  -b:v:0 4000k \
  -b:v:1 3000k \
  -b:v:2 2000k \
  -b:v:3 1000k \
  -s:v:2 1280x720 \
  -s:v:3 640x360 \
  -profile:v:0 high \
  -profile:v:1 high \
  -profile:v:2 high \
  -profile:v:3 high \
  -bf 1 \
  -keyint_min $GOP \
  -g $GOP \
  -seg_duration $segment \
  -sc_threshold 0 \
  -b_strategy 0 \
  -use_template 1 \
  -use_timeline 0 \
  -media_seg_name chunks/stream-\$RepresentationID\$-\$Bandwidth\$-\$Number%05d\$.m4s \
  -init_seg_name inits/stream-\$RepresentationID\$-\$Bandwidth\$.m4s \
  -adaptation_sets "id=0,streams=v id=1,streams=a" \
  -hls_playlist 1 \
  -f dash "media/media.mpd" || { echo; echo "FFmpeg could not finish for some reason."; echo; read -n 1 -s -r -p "Press any key to exit... "; exit 1; }

  echo

done

echo && echo "Finished encoding" && echo

# Rename "master.m3u8" to "media.m3u8"
mv "media/master.m3u8" "media/media.m3u8"

echo "The streams were saved in a folder called 'media' in the same directory as your source files." && echo

# Pause
read -n 1 -s -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
