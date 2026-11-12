#!/bin/bash

# Echo current directory
echo; pwd; echo

# Script title
echo "This script uses FFprobe to generate a log file of keyframe positions"; echo

# Check if FFmpeg exists
echo "Checking for FFprobe..."; echo;
if command -v ffprobe >/dev/null 2>&1 ; then
  echo "FFprobe is installed."; echo;
else
  echo >&2 "FFprobe is not installed. Please install it then try again."; echo;
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

  # If on WSL use wslpath to convert windows paths to Unix
  if command -v wslpath >/dev/null 2>&1; then
    # If the path is quoted and contains a space...
    if [[ "$input" =~ ^\"(.*\ .*)\"$ ]]; then
      # Remove the quotes
      input="${BASH_REMATCH[1]}"
    fi
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

# Pause for input
read -n 1 -s -r -p "Press any key to continue... "
echo

# Make directory

if [ ! -d "logs" ]; then
  mkdir "logs";
fi

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  # Remove file extension
  j="${i%.*}"

  # Re-encode with FFmpeg
  # See https://goo.gl/xak49p probesize is optional and only prevents warnings
  ffprobe "$i" \
  -probesize 10000000 \
  -select_streams v \
  -show_frames \
  -of csv \
  -show_entries frame=coded_picture_number,key_frame,pict_type > "logs/${j}.csv" || { echo; echo "FFmpeg could not finish for some reason."; echo; read -n 1 -s -r -p "Press any key to exit... "; exit 1; }

  echo; echo "FFprobe complete. The log was saved as ${j}.csv in 'logs'."; echo;

done

# Pause
read -n 1 -s -r -p "Press any key to exit... "
echo

exit 0
