#!/bin/bash

# Echo current directory
pwd
echo

# Script title
echo "This script encodes video at a constant rate factor using libx264 and saves it as *.mp4"
echo

echo "Checking for FFmpeg..."
echo

# Check if FFmpeg exists
ffmpeg -version >/dev/null 2>&1 || { echo >&2 "FFmpeg is not installed. Please install it then try again.";
read -n1 -r -p "Press any key to exit..."
exit 1; }

echo "FFmpeg is installed."
echo

echo "Please drag the folder containing the video(s) to be encoded into this window and press enter..."
echo

# Assign selected directory path to variable
IFS="" read -r input
echo

# Evaluate path for spaces and escaped characters
eval "files=( $input )"

# Change directory to selected directory
cd "${files}"

# regex for numbers
isNumerical='^[0-9]+([.][0-9]+)?$'

# Framerate
read -ep "Press enter the desired framerate... " framerate
echo

# If the framerate is not a number
while [[ ! $framerate =~ $isNumerical ]]
do
  read -ep "The framerate must be a number. Please try again... " framerate
  echo
done

# Resolution
read -ep "Press enter the desired height... " height
echo

# If the height is not a number
while [[ ! $height =~ $isNumerical ]]
do
  read -ep "The height must be a number. Please try again... " height
  echo
done

# Calculate the width
width=$((height*16/9))

# Disable case sensitivity and don't print errors for missing file types
shopt -s nullglob
shopt -s nocaseglob

# List all files with supported video formats
echo "The following files will be encoded at a resolution of ${width}×${height} (16:9) at $framerate frames per second..."
echo

ls -l *.{avi,mkv,mov,mp4,mxf}
echo

# Reset shell options
# shopt -u nullglob
# shopt -u nocaseglob

# Pause for input
read -n1 -r -p "Press any key to continue..."
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
  -crf 20 \
  -preset slow \
  -vf "scale=-2:${height}" \
  -profile:a aac_low -ac 2 -b:a 160k \
  -y "${height}p/${j}.mp4"
  echo

  echo "$i was encoded and saved as ${j}.mp4 in ${height}p"
  echo

done

# Pause for input
read -n1 -r -p "Finished encoding the source file to ${height}p. Press any key to exit... "
echo

exit 0
