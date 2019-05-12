#!/bin/bash

# Echo current directory
pwd
echo

# Script title
echo "This script uses libx264 to encode media with a Constant Rate Factor (CRF) for consistent quality and save it as *.mp4."
echo

echo "Checking for FFmpeg..."
echo

# Check if FFmpeg exists
ffmpeg -version >/dev/null 2>&1 || { echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
read -n1 -r -p "Press any key to exit...";
exit 1; }

echo "FFmpeg is installed."
echo

echo "Please drag the folder containing the media to be encoded into this window and press enter..."
echo

# Assign selected directory path to variable
IFS="" read -r input
echo

# Evaluate path for spaces and escaped characters
eval "files=( $input )"

# Change directory to selected directory
cd "${files}"

# Regex for validating integers
isInteger='^[0-9]+$'

# Framerate
while :; do
  read -ep "Please enter the desired framerate... " framerate
  echo
  [[ $framerate =~ $isInteger ]] || { echo "The framerate must be an integer number. Please try again... "; echo; continue; }
  break
done

# Constant Rate Factor
while :; do
  read -ep "Please enter the Constant Rate Factor from 0 to 51... " crf
  echo
  [[ $crf =~ $isInteger ]] || { echo "The Constant Rate Factor must be an integer number. Please try again... "; echo; continue; }
  if (($crf >= 0 && $crf <= 51)); then
    break
  else
    echo "The Constant Rate Factor must be an integer between 0 and 51. Please try again... "
    echo
  fi
done

# Resolution
while :; do
  read -ep "Please enter the desired video height... " height
  echo
  [[ $height =~ $isInteger ]] || { echo "The video height must be an integer number. Please try again... "; echo; continue; }
  break
done

# Calculate the width
width=$((height*16/9))

# Disable case sensitivity and don't print errors for missing file types
shopt -s nullglob
shopt -s nocaseglob

# List all files with supported video formats
echo "The following files will be encoded with CRF ${crf} at a resolution of ${width}×${height} (16:9) at ${framerate} frames per second..."
echo

ls -l *.{avi,mkv,mov,mp4,mxf}
echo

# Reset shell options
# shopt -u nullglob
# shopt -u nocaseglob

# Pause for input
read -n1 -r -p "Press any key to continue... "
echo

# Make directory
if [ ! -d "${height}p" ]; then
  mkdir "${height}p";
fi

echo "Encoding ${height}p"
echo

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  # Remove file extension
  j="${i%.*}"

  # Re-encode with FFmpeg
  ffmpeg -i "$i" \
  -movflags +faststart \
  -metadata:s:v:0 language=eng \
  -metadata:s:a:0 language=eng \
  -r $framerate \
  -c:v libx264 \
  -crf $crf \
  -preset slow \
  -vf "scale=-2:${height}" \
  -profile:a aac_low -ac 2 -b:a 160k \
  -y "${height}p/${j}.mp4"
  echo

  echo "${i} was encoded and saved as ${j}.mp4 in ${height}p"
  echo

done

# Pause for input
echo "The following files were saved in a folder called '${height}p' in the same directory as your source files:"
echo
ls -l ${height}p/*.mp4
echo

# Pause
read -n1 -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
