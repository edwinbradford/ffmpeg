#!/bin/bash

# Script title
echo; echo "This script uses FFmpeg to list media in uncompressed formats, encode it with the FFV1 codec, verify the encode exact matches the original and if so write the encode to a new file with a _ffv1.xxx suffix. Existing files with both the FFV1 codec and the _ffv1.xxx suffix are decoded back to the original format and the _ffv1.xxx suffix removed."; echo;

# Check if FFmpeg exists
echo "Checking for FFmpeg..."; echo
if command -v ffmpeg >/dev/null 2>&1 && command -v ffprobe >/dev/null 2>&1; then
  echo "FFmpeg is installed."; echo
else
  echo >&2 "FFmpeg (including ffprobe) is not installed. Please install it then try again."; echo
  read -n 1 -s -r -p "Press any key to exit... "
  exit 1
fi

# Matches Windows-style paths (C:\... or C:/... or \\server\share)
win_path_re='^([A-Za-z]:[\\/]|\\\\)'

# Matches the archive record this script stores in the FFV1 file's comment tag, e.g.
# "[ffv1-archive codec=rawvideo pix_fmt=bgr24]". Any comment the source already had is kept in front of it.
tag_re='\[ffv1-archive codec=([^] ]+) pix_fmt=([^] ]+)\]$'

# Print the value of a format-level metadata tag ($2, case-insensitive) of file $1
get_tag() {
  ffprobe -v error -show_entries format_tags -of default=nw=1 "./$1" </dev/null 2>/dev/null \
    | grep -i -m1 "^TAG:$2=" | cut -d= -f2-
}

# Print a property ($2, e.g. pix_fmt or codec_name) of the first video stream of file $1
get_video() {
  ffprobe -v error -select_streams v:0 -show_entries "stream=$2" -of default=nw=1:nk=1 "./$1" </dev/null 2>/dev/null \
    | head -n 1
}

# Print a fingerprint (hash) of file $1's decoded video, converted to pixel format $2 (if
# given), plus its decoded audio. Identical fingerprints mean identical pictures and sound.
# Prints nothing (and returns 1) if the file cannot be decoded, so a failure can never
# look like a match.
fingerprint() {
  local pix=() v a acount
  [[ -n $2 ]] && pix=(-pix_fmt "$2")
  v="$(ffmpeg -nostdin -v error -i "./$1" -map 0:v:0 "${pix[@]}" -fps_mode passthrough -f md5 - 2>/dev/null)"
  [[ $v == MD5=* ]] || return 1
  acount="$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "./$1" </dev/null 2>/dev/null | wc -l)"
  a="none"
  if (( acount > 0 )); then
    a="$(ffmpeg -nostdin -v error -i "./$1" -map 0:a -f md5 - 2>/dev/null)"
    [[ $a == MD5=* ]] || return 1
  fi
  echo "${v};${acount};${a}"
}

# Video codecs worth archiving as FFV1: uncompressed formats, where FFV1 saves a lot of space.
# Anything else (H.264, HEVC, ProRes, ...) is left alone because re-encoding it to FFV1 would
# only make it bigger. Names are as ffprobe reports them; add more here (space separated,
# keep a space at each end) if you want other codecs included.
archive_codecs=" rawvideo v210 v210x v308 v408 v410 r210 r10k avrp avui ayuv 012v y41p yuv4 "

# Report files that were left out of the lists below (uses the variables set in the search)
print_left_out() {
  if (( skipped )); then
    echo "${skipped} other file(s) were left out because their counterpart already exists."; echo
  fi
  if (( left_out_total )); then
    echo "${left_out_total} file(s) were left out because of their video codec (${left_out_text}). Only uncompressed video is archived as FFV1, and only FFV1 files are restored."; echo
  fi
}

# Remember where the script was launched so relative paths always resolve from here
start_dir="$PWD"

# Main loop: select a folder, process it, then return here until the user quits
while :; do

  # Source media
  echo "Enter the path to synchronise and press enter or press [Q] to quit... "; echo

  # Check for supported media files
  while :; do
    # Assign selected directory path to variable (-e enables line editing and Tab
    # completion; exit cleanly on EOF / Ctrl-D)
    IFS= read -e -r input || exit 1
    echo

    # Trim leading and trailing whitespace (drag and drop often adds a trailing space)
    input="${input#"${input%%[![:space:]]*}"}"
    input="${input%"${input##*[![:space:]]}"}"

    if [[ -z $input ]]; then
      echo "No folder entered. Please try again, or type [q] to quit... "; echo
      continue
    fi

    # Quit option (a quoted "q" is treated as a folder name, and ./q is a folder named q)
    if [[ $input == [Qq] ]]; then
      echo "Goodbye."; echo
      exit 0
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
        echo "Could not convert that Windows path. Please try again, or type [q] to quit... "; echo
        continue
      }
    else
      if (( ! quoted )); then
        # Unquoted Unix path: remove backslash escapes (e.g. "My\ Folder" -> "My Folder")
        input="$(printf '%s' "$input" | sed -E 's/\\(.)/\1/g')"
      fi

      # Expand a leading ~ for typed paths ("~" or "~/...")
      case $input in
        "~"   ) input="$HOME";;
        "~/"* ) input="$HOME/${input:2}";;
      esac
    fi

    # Return to the launch directory first so a relative path is never resolved
    # from a folder that an earlier attempt moved into
    cd -- "$start_dir" || exit 1

    # Change directory to selected directory
    cd -- "$input" 2>/dev/null || {
      echo "Could not open that folder. Please try again, or type [q] to quit... "; echo
      continue
    }

    # Collect supported regular files in the folder and ALL its subfolders.
    # Supported types are the containers that can hold FFV1: avi, mkv and mov.
    # The file name decides what happens to each file:
    #   name.avi       -> archive: encode to name_ffv1.avi  (skipped if that already exists)
    #   name_ffv1.avi  -> restore: decode to name.avi       (skipped if that already exists)
    # ffprobe checks each file's video codec: only uncompressed codecs (see archive_codecs)
    # are archived, and only genuine FFV1 files are restored. Everything else is counted
    # by codec and reported, but never touched.
    # Nothing is ever overwritten. Also skipped: temporary files from an interrupted run,
    # a leftover 'mkv' folder from older versions of this script, hidden files and folders
    # (this also avoids macOS "._name.avi" junk files), and symlinks (so linked folders
    # can't cause loops). Paths are stored relative to the selected folder, sorted and
    # null-delimited so any filename is safe.
    files=()
    restore_files=()
    skipped=0
    declare -A left_out=()
    while IFS= read -r -d '' f; do
      f="${f#./}"
      base="${f%.*}"
      ext="${f##*.}"
      if [[ $base == *_ffv1 ]]; then
        if [[ -e "${base%_ffv1}.${ext}" ]]; then
          (( skipped++ ))
        else
          codec="$(get_video "$f" codec_name)"
          if [[ $codec == ffv1 ]]; then
            restore_files+=("$f")
          else
            key="${codec:-unknown}"
            left_out[$key]=$(( ${left_out[$key]:-0} + 1 ))
          fi
        fi
      else
        if [[ -e "${base}_ffv1.${ext}" ]]; then
          (( skipped++ ))
        else
          codec="$(get_video "$f" codec_name)"
          if [[ -n $codec && $archive_codecs == *" $codec "* ]]; then
            files+=("$f")
          else
            key="${codec:-unknown}"
            left_out[$key]=$(( ${left_out[$key]:-0} + 1 ))
          fi
        fi
      fi
    done < <(
      find . \( -path ./mkv -o -name '.?*' \) -prune -o -type f ! -iname '*.ffv1tmp.*' \
        \( -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' \) \
        -print0 2>/dev/null | sort -z
    )

    # Summarise files left out because of their codec, e.g. "2 x h264, 1 x prores"
    left_out_total=0
    left_out_text=""
    if (( ${#left_out[@]} )); then
      while IFS= read -r c; do
        left_out_text+="${left_out_text:+, }${left_out[$c]} x ${c}"
        (( left_out_total += left_out[$c] ))
      done < <(printf '%s\n' "${!left_out[@]}" | sort)
    fi

    if (( ${#files[@]} + ${#restore_files[@]} )); then
      if (( ${#files[@]} )); then
        echo "Found ${#files[@]} file(s) to re-encode as FFV1, including those in subfolders... "; echo
        printf '%s\n' "${files[@]}"; echo
      fi
      if (( ${#restore_files[@]} )); then
        echo "Found ${#restore_files[@]} FFV1 file(s) to restore to their original format (the _ffv1 suffix is removed)... "; echo
        for r in "${restore_files[@]}"; do
          echo "${r}  ->  ${r%_ffv1.*}.${r##*.}"
        done
        echo
      fi
      print_left_out
      break
    elif (( skipped || left_out_total )); then
      print_left_out
      echo "Nothing to do here. Please try again, or type [q] to quit... "; echo
    else
      echo "No supported media files found. Please try again, or type [q] to quit... "; echo
    fi
  done

  # Confirm before processing
  if (( ${#files[@]} && ${#restore_files[@]} )); then
    question="Proceed to re-encode the files as FFV1 and restore the FFV1 files [y][n]? "
  elif (( ${#restore_files[@]} )); then
    question="Proceed to restore these files from FFV1 [y][n]? "
  else
    question="Proceed to re-encode these files as FFV1 [y][n]? "
  fi

  while true; do
    read -r -p "$question" yn
    case $yn in
      [Yy]* ) echo; break;;
      [Nn]* ) echo; echo "Nothing was processed. Returning to folder selection..."; echo; continue 2;;
      * ) echo; echo "Please enter 'y' for yes or 'n' for no... "; echo;;
    esac
  done

  created=()
  failed=()

  # ARCHIVE: re-encode supported video files to FFV1 with FFmpeg
  for i in "${files[@]}"; do

    # Output sits next to the source: name_ffv1.ext, same extension as the source.
    # Encode to a temporary name first so an interrupted run never leaves a partial
    # file that looks finished.
    base="${i%.*}"
    ext="${i##*.}"
    out="${base}_ffv1.${ext}"
    tmp="${base}_ffv1.ffv1tmp.${ext}"

    # Record what the source was so a restore can put it back. The pixel format is read
    # from the source (not hard-coded) and stored in the output's comment tag; FFmpeg
    # chooses the matching FFV1 pixel layout itself. Any existing comment is kept.
    orig_pix="$(get_video "$i" pix_fmt)"
    orig_codec="$(get_video "$i" codec_name)"
    orig_comment="$(get_tag "$i" comment)"
    meta=()
    if [[ -n $orig_pix && -n $orig_codec ]]; then
      meta=(-metadata "comment=${orig_comment:+$orig_comment }[ffv1-archive codec=${orig_codec} pix_fmt=${orig_pix}]")
    fi

    echo "Archiving: ${i}  (${orig_codec:-unknown} ${orig_pix:-unknown})"; echo

    ffmpeg -nostdin -hide_banner -loglevel info -stats -i "$i" \
      -map 0:v -map "0:a?" \
      -c:v ffv1 \
      -c:a copy \
      -level 3 \
      -g 1 \
      -context 1 \
      -coder 2 \
      -slices 4 \
      -slicecrc 1 \
      "${meta[@]}" \
      -y "$tmp" || {
        rm -f -- "$tmp"
        echo; echo "FFmpeg could not finish for some reason."; echo
        read -n 1 -s -r -p "Press any key to exit... "
        exit 1
      }

    # Verify before keeping: the decoded FFV1 video and audio must be bit-for-bit identical
    # to the source's, compared in the source's own pixel format. A file that fails is
    # deleted so a bad archive can never sit beside the only good copy.
    echo; echo "Verifying that the FFV1 version is identical to ${i}... "
    src_fp="$(fingerprint "$i" "$orig_pix")"
    out_fp="$(fingerprint "$tmp" "$orig_pix")"
    if [[ -z $src_fp || $src_fp != "$out_fp" ]]; then
      rm -f -- "$tmp"
      failed+=("$i")
      echo; echo "VERIFICATION FAILED: the FFV1 version of ${i} did not match the original, so it was deleted. Keep the original."; echo
      continue
    fi

    mv -f -- "$tmp" "$out" || {
      echo >&2 "Could not save '$out'."; echo
      read -n 1 -s -r -p "Press any key to exit... "
      exit 1
    }

    created+=("$out")
    echo "Verified identical."; echo "${i} was encoded with FFV1 and saved as ${out}."; echo

  done

  # RESTORE: decode FFV1 files back to uncompressed video in their original pixel format
  for r in "${restore_files[@]}"; do

    base="${r%.*}"
    ext="${r##*.}"
    out="${base%_ffv1}.${ext}"
    tmp="${base%_ffv1}.ffv1tmp.${ext}"

    # Read the archive record written when the file was encoded
    comment="$(get_tag "$r" comment)"
    if [[ $comment =~ $tag_re ]]; then
      pix="${BASH_REMATCH[2]}"
      rest="${comment%"${BASH_REMATCH[0]}"}"
      rest="${rest% }"
      note="original pixel format ${pix}"
    else
      # No record (e.g. file made by an earlier version): use the FFV1 file's own pixel
      # format. FFV1 stores 24-bit RGB with a spare byte (bgr0), which converts back to
      # bgr24 exactly.
      pix="$(get_video "$r" pix_fmt)"
      case $pix in
        bgr0 ) pix="bgr24";;
        rgb0 ) pix="rgb24";;
      esac
      rest="$comment"
      note="no archive record found, assuming ${pix:-unknown}"
    fi

    if [[ -z $pix ]]; then
      echo "Skipping ${r}: could not determine its pixel format."; echo
      continue
    fi

    # Matroska needs this flag to store raw RGB video
    extra=()
    [[ ${ext,,} == mkv ]] && extra=(-allow_raw_vfw 1)

    echo "Restoring: ${r}  (${note})"; echo

    # The restored file carries the original comment (our archive record is removed)
    ffmpeg -nostdin -hide_banner -loglevel info -stats -i "$r" \
      -map 0:v -map "0:a?" \
      -c:v rawvideo -pix_fmt "$pix" \
      -c:a copy \
      -metadata "comment=${rest}" \
      "${extra[@]}" \
      -y "$tmp" || {
        rm -f -- "$tmp"
        echo; echo "FFmpeg could not finish for some reason."; echo
        read -n 1 -s -r -p "Press any key to exit... "
        exit 1
      }

    mv -f -- "$tmp" "$out" || {
      echo >&2 "Could not save '$out'."; echo
      read -n 1 -s -r -p "Press any key to exit... "
      exit 1
    }

    created+=("$out")
    echo; echo "${r} was restored as ${out}."; echo

  done

  if (( ${#created[@]} )); then
    echo "The following files were created:"
    echo
    printf '%s\n' "${created[@]}"
    echo
  fi

  if (( ${#failed[@]} )); then
    echo "WARNING: ${#failed[@]} file(s) FAILED verification. No FFV1 version was kept, so these originals must NOT be deleted:"
    echo
    printf '%s\n' "${failed[@]}"
    echo
  fi

  echo "Finished. Returning to folder selection..."; echo

done