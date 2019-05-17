#!/bin/bash

# Echo current directory
pwd
echo

# Script title
echo "This script uses libx264 to encode and package media for streaming as MPEG-DASH and HLS streams."
echo

echo "Checking for FFmpeg..."
echo

# Check if FFmpeg exists
ffmpeg -version >/dev/null 2>&1 || { echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
read -n1 -r -p "Press any key to exit...";
exit 1; }

echo "FFmpeg is installed."
echo

echo "Drag and drop the folder containing the media to be re-encoded into this window and press enter..."
echo

# Assign selected directory path to variable
IFS="" read -r input
echo

# Evaluate path for spaces and escaped characters
eval "files=( $input )"

# Change directory to selected directory
cd "${files}"

# Regex for validating numbers
isNumeral='^[0-9]+([.][0-9]+)?$'

# Framerate
while :; do
  read -ep "Please enter the framerate... " framerate
  echo
  [[ $framerate =~ $isNumeral ]] || { echo "The framerate must be a number. Please try again... "; echo; continue; }
  break
done

# Fragment size, recommendation is 2 to 4
while :; do
  read -ep "Please enter the keyframe interval. e.g. 3.2 (s) for 30fps and 48kHz... " fragment
  echo
  [[ $fragment =~ $isNumeral ]] || { echo "The fragment size must be a number only. Please try again... "; echo; continue; }
  break
done

# Calculate the GOP
GOP=$((framerate*fragment))


# Stream segment length, multiple of fragment size
while :; do
  read -ep "Please enter the segment length in multiples of the keyframe interval... " segment
  echo
  [[ $segment =~ $isNumeral ]] || { echo "The segment length must be a number. Please try again... "; echo; continue; }
  break
done

# Disable case sensitivity and don't print errors for missing file types
shopt -s nullglob
shopt -s nocaseglob

# List all files with supported video formats
echo "The following files will be encoded at ${framerate} fps with a GOP of ${GOP} and segment length of ${segment}s... "
echo

ls -l *.{avi,mkv,mov,mp4,mxf}
echo

# Reset shell options
# shopt -u nullglob
# shopt -u nocaseglob

# Pause for input
read -n1 -r -p "Press any key to continue... "
echo

# Make directories

if [ ! -d "logs" ]; then
  mkdir "logs";
fi

if [ ! -d "media" ]; then
  mkdir "media";
  mkdir "media/chunks";
  mkdir "media/inits";
fi

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  ffmpeg \
  -channel_layout stereo \
  -i "$i" \
  -map 0:v:0 \
  -map 0:a:0 \
  -map 0:v:0 \
  -map 0:a:0 \
  -map 0:v:0 \
  -map 0:a:0 \
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
  -use_timeline 1 \
  -adaptation_sets "id=0,streams=v id=1,streams=a" \
  -hls_playlist 1 \
  -f dash "media/media.mpd"

  echo

done

# -media_seg_name chunks/$RepresentationID/$Number/$.$ext$ \
# -init_seg_name inits/$RepresentationID/$.$ext$ \

echo && echo "Finished encoding" && echo

# Rename "master.m3u8" to "media.m3u8"
mv "media/master.m3u8" "media/media.m3u8"

echo "The streams were saved in a folder called 'media' in the same directory as your source files." && echo

# Pause
read -n1 -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
