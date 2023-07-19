# batch-hevc-encoder

This tool aims to automate the batch encoding of video files to hevc, using FFmpeg for that.

## Usage

First, backup your files. This script does not intend to overwrite any files, but it has not been tested extensively.
Currently, the following options are supported: -f, -p, -o -v:

```
-h                          Print help.
-f <crf>                    Set the Constant Rate Factor. Default: 23
-p <preset>                 Set the preset. Default: medium
-o <output>                 Set the output folder. Default: output/
-v                          Enable verbose of FFmpeg.
```
you can print this table by using ``-h`` option.

By default, FFmpeg output is suppressed. You can enable it by using -v option. 
It is not possible to set the input folder, by design it will try to encode all videos in **current folder**. 

## FFmpeg

[FFmpeg](https://ffmpeg.org/) is responsible for encoding and it is **NOT** distributed by this project, you must install it first. It is recommended that you check it's license before use.