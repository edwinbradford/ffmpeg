#!/bin/bash

# Echo current directory
pwd
echo

# Script title
echo "This script uses FFV1 compression to encode media in a lossless format and save it as cross platform *.mkv."
echo

echo "Checking for FFmpeg..."
echo

# Check if FFmpeg exists
ffmpeg -version >/dev/null 2>&1 || { echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
read -n1 -r -p "Press any key to exit..."
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
echo "The following files will be encoded as FFV1 *.mkv files..."
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
if [ ! -d "mkv" ]; then
  mkdir "mkv";
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
  -c:v ffv1 \
  -c:a copy \
  -y "mkv/${j}.mkv"
  echo

  echo "${i} was encoded with FFV1 and saved as ${j}.mkv in 'mkv'."
  echo

done

echo "The following files were saved in a folder called 'mkv' in the same directory as your source files:"
echo
ls -l mkv/*.mkv
echo

# Pause
read -n1 -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
