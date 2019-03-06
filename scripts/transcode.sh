#! /bin/bash

fn="$1"
audio="$2"

dirpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo "transcode.sh <filename> [audio_track]"
    exit 1
}

if [ "X$fn" == "X" ]; then
    usage
fi

if [ "X$audio" == "X" ]; then
    # try to dig out the radio audio channel from ffmpeg
    audio=$(ffmpeg -i "$fn" 2>&1 | grep 0x103 | sed -e 's,.*\(.\)\[0x103\].*,\1,')

    if [ "X$audio" == "X" ]; then
        ffprobe "$fn"
        exit
    fi
fi

if [ ! -f "$fn.silence" ]; then
    $dirpath/getsilence.sh "$fn" > "$fn.silence"
fi

silences=$($dirpath/process_silence.py "$fn.silence" $audio)

echo ffmpeg -i "'$fn'" ${silences} "'media/$fn-$audio.mp4'" | sh

#ffmpeg -i "$fn" -map 0:0:0 -map 0:$audio:1 -vcodec copy "media/$fn-$audio.mp4"
