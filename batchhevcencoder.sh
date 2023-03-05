#!/bin/bash

# Perform batch videos encoding to hevc using ffmpeg
# Author: Pedro Henrique da Silva Palhares

OUTPUT_FOLDER="output/"

if [[ ! -d $OUTPUT_FOLDER ]]; then 
  mkdir $OUTPUT_FOLDER || exit 1
fi

for f in *; do

  if [[ -d $f ]]; then
    continue
  fi

  fname="${f%.*}"
  ext="${f##*.}"

  check_vid=$(ffprobe -v quiet -show_streams $f | grep -E "codec_type=video" -A 1)
  check_hevc=$(echo "$check_vid" | grep -E "codec_tag_string=hev1" -A 1)
  
  echo "$fname $check_hevc"

  if [[ ! -z $check_vid && -z $check_hevc ]]; then 
    new_fname="$OUTPUT_FOLDER/${fname}_x265.mp4"
    
    if [[ ! -e $new_fname ]]
    then
      echo "convert"
    else
      echo "OK"
    fi
  elif [[ ! -z $check_vid ]]; then
    [[ $fname == *"x265" ]] && new_fname="$OUTPUT_FOLDER/$f" || new_fname="$OUTPUT_FOLDER/${fname}_x265.$ext"
    [ -e $new_fname ] || cp "$f" "$new_fname"
  fi
done
