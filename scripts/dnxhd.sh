#!/bin/bash

# Echo current directory
pwd
echo

# Script title
echo "This script uses DNxHD compression to encode media in DNxHD 90 format and save it as cross platform *.mxf."
echo

echo "Checking for FFmpeg..."
echo

# Check if FFmpeg exists
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
read -n 1 -s -r -p "Press any key to exit...";
exit 1; }

echo "FFmpeg is installed."
echo

echo "Drag and drop the folder containing the media to be encoded into this window and press enter..."
echo

# Assign selected directory path to variable
IFS="" read -r input
echo

# Evaluate path for spaces and escaped characters
eval "files=( $input )"

# Change directory to selected directory
cd "${files}"

# Disable case sensitivity and don't print errors for missing file types
shopt -s nullglob
shopt -s nocaseglob

# List all files with supported video formats
echo "The following files will be encoded as DNxHD 90 *.mxf files..."
echo
ls -l *.{avi,mkv,mov,mp4,mxf}
echo

# Reset shell options
# shopt -u nullglob
# shopt -u nocaseglob

# Pause for input
read -n 1 -s -r -p "Press any key to continue... "
echo

# Make directory
if [ ! -d "mxf" ]; then
  mkdir "mxf";
fi

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  # Remove file extension
  j="${i%.*}"

  # Re-encode with FFmpeg
  ffmpeg -i "$i" \
  -r 60 \
  -c:v dnxhd \
  -vf "scale=1920:1080" \
  -pix_fmt yuv422p \
  -b:v 90M \
  -c:a pcm_s16le \
  -ar 48k \
  -y "mxf/${j}.mxf"
  echo

  echo "${i} was encoded with DNxHD 90 and saved as ${j}.mxf in 'mxf'."
  echo

done

echo "The following files were saved in a folder called 'mxf' in the same directory as your source files:"
echo
ls -l mxf/*.mxf
echo

# Pause
read -n 1 -s -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
