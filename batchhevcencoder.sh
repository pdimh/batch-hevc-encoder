#!/bin/bash

# Perform batch encoding of videos to HEVC using ffmpeg
# Author: Pedro Henrique da Silva Palhares

crf=23
output_folder="output"
preset="medium"
verbose="-loglevel error -x265-params log-level=none"

# Print help message
print_help() {
  echo "Perform batch encoding of videos to HEVC using ffmpeg."
  echo
  echo "Sintax: batchhevcencoder.sh [-h|-?] [-f <crf>] [-o <output>] [-p <preset>]"
  echo "  -h                          Print this help."
  echo "  -f <crf>                    Set the Constant Rate Factor. Default: $crf"
  echo "  -p <preset>                 Set the preset. Default: $preset"
  echo "  -o <output>                 Set the output folder. Default: $output_folder/"
  echo "  -v                          Enable verbose of ffmpeg."
  echo
}

print_info() {
  local BLUE='\e[1;94m'
  local YELLOW='\e[0;93m'
  local NC='\e[0m'
  echo -e "[${BLUE}INFO${NC}] ${YELLOW}$@${NC}"
}

print_err() {
  local RED='\e[1;31m'
  local LRED='\e[0;91m'
  local YELLOW='\e[0;93m'
  local NC='\e[0m'
  echo -e "[${RED}ERROR${NC}] ${LRED}$@${NC}" >&2
}

print_success() {
  local BLUE='\e[1;94m'
  local GREEN='\e[1;92m'
  local NC='\e[0m'
  echo -e "[${BLUE}INFO${NC}] ${GREEN}$@${NC}"
}

encode() {
  local filename=$1
  local crf=$2
  local preset=$3
  local output_file=$4

  print_info "Encoding $filename..."
  ffmpeg -i "$filename" -c:v libx265 -crf $crf -preset $preset -c:a copy $verbose -n "$output_file"
  if [[ $? -ne "0" ]]; then
    print_err "Error encoding $filename"
    rm $output_file
    exit 1
  fi
}

while getopts ": h f: o: p: v" opt; do
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
    v)
      verbose=""
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

  if [[ ! -z $check_vid && -z $check_hevc ]]; then 
    new_fname="$output_folder/${fname}_x265.mp4"

    if [[ ! -e $new_fname ]]
    then
      encode $f $crf $preset $new_fname
    else
      print_info "$new_fname already exists."
    fi
  elif [[ ! -z $check_vid ]]; then
    [[ $fname == *"x265" ]] && new_fname="$output_folder/$f" || new_fname="$output_folder/${fname}_x265.$ext"
    [ -e $new_fname ] || cp -n "$f" "$new_fname"
  fi
done
print_success "Finished! Check if all files were correctly encoded."
