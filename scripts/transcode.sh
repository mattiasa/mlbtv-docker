#! /bin/bash

fn=$1
audio=$2

dirpath=$(dirname $0)

usage() {
    echo "transcode.sh <filename> [audio_track]"
    exit 1
}

if [ "X$fn" == "X" ]; then
    usage
fi

if [ "X$audio" == "X" ]; then
    # try to dig out the radio audio channel from ffmpeg
    audio=$(ffmpeg -i "$fn" 2>&1 | grep 0x1e3 | sed -e 's,.*\(.\)\[0x1e3\].*,\1,')

    if [ "X$audio" == "X" ]; then
        ffmpeg -i "$fn"
        exit
    fi
fi

if [ ! -f $fn.silence ]; then
    $dirpath/getsilence.sh $fn > $fn.silence
fi

silences=$($dirpath/process_silence.py $fn.silence $audio)

echo ffmpeg -i "$fn" ${silences} "media/$fn-$audio.mp4" | sh

#ffmpeg -i "$fn" -map 0:0:0 -map 0:$audio:1 -vcodec copy "media/$fn-$audio.mp4"
