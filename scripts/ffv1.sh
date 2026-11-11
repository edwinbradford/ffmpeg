#!/bin/bash

# Script title
echo "This script uses FFmpeg to encode media with the FFV1 lossless codec and save it in the cross-platform .mkv format."; echo

# Check if FFmpeg exists
echo "Checking for FFmpeg..."; echo
if command -v ffmpeg >/dev/null 2>&1; then
  echo "FFmpeg is installed."; echo
else
  echo >&2 "FFmpeg is not installed. Please install it then try again."; echo
  read -n 1 -s -r -p "Press any key to exit... "
  exit 1
fi

# Source media
echo "Drag and drop the folder containing the media into this window and press enter..."; echo

# Disable case sensitivity and error reporting for missing file types
shopt -s nullglob
shopt -s nocaseglob

# Matches Windows-style paths (C:\... or C:/... or \\server\share)
win_path_re='^([A-Za-z]:[\\/]|\\\\)'

# Check for supported media files
while :; do
  # Assign selected directory path to variable (exit cleanly on EOF / Ctrl-D)
  IFS= read -r input || exit 1
  echo

  # Trim leading and trailing whitespace (drag and drop often adds a trailing space)
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"

  if [[ -z $input ]]; then
    echo "No folder entered. Please try again... "; echo
    continue
  fi

  # Remove surrounding single or double quotes
  quoted=0
  if [[ ${#input} -ge 2 && ( $input == \"*\" || $input == \'*\' ) ]]; then
    input="${input:1:${#input}-2}"
    quoted=1
  fi

  if [[ $input =~ $win_path_re ]] && command -v wslpath >/dev/null 2>&1; then
    # Windows path on WSL: convert to Unix
    input="$(wslpath -u "$input")" || {
      echo "Could not convert that Windows path. Please try again... "; echo
      continue
    }
  elif (( ! quoted )); then
    # Unquoted Unix path: remove backslash escapes (e.g. "My\ Folder" -> "My Folder")
    input="$(printf '%s' "$input" | sed -E 's/\\(.)/\1/g')"
  fi

  # Change directory to selected directory
  cd -- "$input" 2>/dev/null || {
    echo "Could not open that folder. Please try again... "; echo
    continue
  }

  # Collect supported regular files (skips directories and broken links)
  files=()
  for f in *.{avi,mkv,mov,mp4,mxf}; do
    [[ -f $f ]] && files+=("$f")
  done

  if (( ${#files[@]} )); then
    echo "The following supported media files were found... "; echo
    ls -l -- "${files[@]}"; echo
    break
  else
    echo "No supported media files found. Please try again... "; echo
  fi
done

# Pause for input
read -n 1 -s -r -p "Press any key to continue... "
echo

# Make directory
if [[ -d mkv ]]; then
  echo; echo "The existing 'mkv' folder in your directory will be deleted."; echo
  while true; do
    read -r -p "Delete? [y] / [n] " yn
    case $yn in
      [Yy]* ) rm -rf -- "mkv"; break;;
      [Nn]* ) echo; echo "Nothing was deleted or encoded. Exiting..."; echo; exit 0;;
      * ) echo; echo "Please enter 'y' for yes or 'n' for no... "; echo;;
    esac
  done
fi

mkdir -- "mkv" || { echo >&2 "Could not create the 'mkv' folder."; exit 1; }

# Re-encode supported video files with FFmpeg
for i in "${files[@]}"; do

  # Remove file extension
  j="${i%.*}"

  # Re-encode with FFmpeg
  ffmpeg -nostdin -i "$i" \
    -map 0:v -map "0:a?" \
    -c:v ffv1 \
    -c:a copy \
    -level 3 \
    -g 1 \
    -context 1 \
    -coder 2 \
    -slices 4 \
    -slicecrc 1 \
    -y "mkv/${j}.mkv" || {
      echo; echo "FFmpeg could not finish for some reason."; echo
      read -n 1 -s -r -p "Press any key to exit... "
      exit 1
    }

  echo; echo "${i} was encoded with FFV1 and saved as ${j}.mkv in 'mkv'."; echo

done

echo "The following files were saved in a folder called 'mkv' in the same directory as your source files:"
echo
ls -l -- mkv/*.mkv
echo

# Pause
read -n 1 -s -r -p "Finished re-encoding all files. Press any key to exit... "
echo