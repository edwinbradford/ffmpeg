#!/bin/bash

# Echo current directory
echo; pwd; echo

# Script title
echo "This script uses FFmpeg to encode media at a Constant Frame Rate (CFR) and save it as *.mp4."; echo;

# Check if FFmpeg exists
echo "Checking for FFmpeg..."; echo;
if command -v ffmpeg >/dev/null 2>&1 ; then
  echo "FFmpeg is installed."; echo;
else
  echo >&2 "FFmpeg is not installed. Please install it then try again."; echo;
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

# Regex for validating integers
isInteger='^[0-9]+$'
isNumeral='^[0-9]+([.][0-9]+)?$'

# Framerate
while :; do
  read -ep "Please enter the desired framerate... " framerate
  echo
  [[ $framerate =~ $isNumeral ]] || { echo "The framerate must be a number. Please try again... "; echo; continue; }
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

# List all files with supported video formats
echo "Your media will be re-encoded with CRF ${crf} at ${framerate} fps..."
echo

# Pause for input
read -n 1 -s -r -p "Press any key to continue... "
echo

# Make directory

if [ -d "mp4" ]; then
  echo; echo "The existing 'mp4' folder in your directory will be deleted."; echo;
  while true; do
    read -p "Delete? [y] / [n] " yn
    case $yn in
      [Yy]* ) rm -rf "mp4"; break;;
      [Nn]* ) exit 0;;
      * ) echo; echo "Please enter 'y' for yes or 'n' for no... " ; echo;;
    esac
  done
fi

mkdir "mp4";

# Re-encode supported video files with FFmpeg
for i in *.{avi,mkv,mov,mp4,mxf}
do

  # Skip file if it is a system file or symlink
  [ -f "$i" ] || break

  # Remove file extension
  j="${i%.*}"

  # Re-encode with FFmpeg
  ffmpeg -i "$i" \
  -r $framerate \
  -c:v libx264 \
  -preset slow \
  -crf $crf \
  -y "mp4/${j}.mp4" || { echo; echo "FFmpeg could not finish for some reason."; echo; read -n 1 -s -r -p "Press any key to exit... "; exit 1; }

  echo; echo "${i} was re-encoded and saved as ${j}.mp4 in mp4"; echo;

done

echo "The following files were saved in a folder called 'mp4' in the same directory as your source files:"
echo
ls -l mp4/*.mp4
echo

# Pause
read -n 1 -s -r -p "Finished re-encoding all files. Press any key to exit... "
echo

exit 0
