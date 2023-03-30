#!/bin/bash

# Perform batch encoding of videos to HEVC using ffmpeg
# Author: Pedro Henrique da Silva Palhares

crf=23
output_folder="output/"
preset="medium"

# Function to print help message
print_help() {
  echo "Perform batch encoding of videos to HEVC using ffmpeg."
  echo
  echo "Sintax: batchhevcencoder.sh [-h|-?] [-f <crf>] [-o <output>] [-p <preset>]"
  echo "  -h                          Print this help."
  echo "  -f <crf>                    Set the Constant Rate Factor. Default: $crf"
  echo "  -p <preset>                 Set the preset. Default: $preset"
  echo "  -o <output>                 Set the output folder. Default: $output_folder"
  echo
}

convert() {
  local filename=$1
  local crf=$2
  local preset=$3
  local output_file=$4

  ffmpeg -i "$filename" -c:v libx265 -crf $crf -preset $preset -c:a copy -n "$output_file"
}

while getopts ": h f: o: p:" opt; do
  case $opt in
    h)
      print_help
      exit 0
      ;;
    f)
      crf="$OPTARG"
      ;;
    o)
      output_folder="$OPTARG"
      ;;
    p)
      preset="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ ! -d $output_folder ]]; then 
  mkdir $output_folder || exit 1
fi

for f in *; do

  if [[ -d $f ]]; then
    continue
  fi

  if [[ $(file -i $f | sed 's/.*\s\+\(.*\)\/.*/\1/') != "video" ]]; then
    continue
  fi

  fname="${f%.*}"
  ext="${f##*.}"

  probe=$(ffprobe -v quiet -select_streams v -show_entries stream=codec_name,codec_type -of default=nw=1 "$f")

  check_vid=$(echo "$probe" | grep "codec_type=video")
  check_hevc=$(echo "$probe" | grep "codec_name=hevc")
  
  echo "$fname $check_vid $check_hevc"

  if [[ ! -z $check_vid && -z $check_hevc ]]; then 
    new_fname="$output_folder/${fname}_x265.mp4"

    if [[ ! -e $new_fname ]]
    then
      convert $f $crf $preset $new_fname
    else
      echo "OK"
    fi
  elif [[ ! -z $check_vid ]]; then
    [[ $fname == *"x265" ]] && new_fname="$output_folder/$f" || new_fname="$output_folder/${fname}_x265.$ext"
    [ -e $new_fname ] || cp -n "$f" "$new_fname"
  fi
done
