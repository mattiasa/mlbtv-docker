#! /bin/bash
fn=$1
audio=$2

usage() {
    echo "getsilence.sh <filename> [audio_track]"
    exit 1
}


if [ "X$fn" == "X" ]; then
    usage
fi

if [ "X$audio" == "X" ]; then
    # try to dig out the tv audio channel from ffmpeg
    audio=$(ffmpeg -i "$fn" 2>&1 | grep 0x1e2 | sed -e 's,.*\(.\)\[0x1e2\].*,\1,')

    if [ "X$audio" == "X" ]; then
        ffmpeg -i "$fn"
        exit
    fi
fi

#ffmpeg -i $1 -vn -af silencedetect=n=-50dB:d=5 -f null - 2>&1 | tr '' '\n' | grep silence_
ffmpeg -i $1 -vn -filter_complex " [0:$audio]silencedetect=n=-50dB:d=5[out] " -map "[out]" -f null - 2>&1 | tr '' '\n' | grep silence_
