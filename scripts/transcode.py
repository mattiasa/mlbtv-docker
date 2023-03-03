#! /usr/bin/env python3.7

import argparse
import ffmpeg
import os
import random
import re
import subprocess
import sys

from pymediainfo import MediaInfo


# Tests

test_filename = "test.ts"

test_silences = [
    '[silencedetect @ 0x1f01040] silence_start: 0',
    '[silencedetect @ 0x1f01040] silence_end: 7.16406 | silence_duration: 7.16406',
    '[silencedetect @ 0x1f01040] silence_start: 102.287',
    '[silencedetect @ 0x1f01040] silence_end: 258.216 | silence_duration: 155.93',
    '[silencedetect @ 0x1f01040] silence_start: 676.583',
    '[silencedetect @ 0x1f01040] silence_end: 787.127 | silence_duration: 110.544',
    '[silencedetect @ 0x1f01040] silence_start: 1634.3',
    '[silencedetect @ 0x1f01040] silence_end: 1757.82 | silence_duration: 123.52',
    '[silencedetect @ 0x1f01040] silence_start: 2040.38',
    '[silencedetect @ 0x1f01040] silence_end: 2167.31 | silence_duration: 126.929',
]


def test_get_track():
    ffp = get_ffprobe(test_filename)
    vid_track = get_track(ffp, "video")

    assert vid_track['codec_type'] == "video"
    assert vid_track['index'] == 0

    tv_aud_track = get_track(ffp, "audio", '0x101')
    assert tv_aud_track['id'] == '0x101'
    assert tv_aud_track['index'] == 1

    radio_aud_track = get_track(ffp, "audio", '0x103')
    assert radio_aud_track['id'] == '0x103'
    assert radio_aud_track['index'] == 3


def test_get_ffprobe():
    ffp = get_ffprobe(test_filename)
    assert ffp is not None

    assert ffp['streams'][3]['index'] == 3

def test_get_silences():
    ffp = get_ffprobe(test_filename)
    tv_aud_track = get_track(ffp, "audio", '0x101')
    silences = detect_silences(test_filename, tv_aud_track)
    assert silences == [(0, 7.16406), (7.16406, 9999999999)]

def test_parse_silences():
    expected = [
        (0, 7.16406),
        (7.16406, 102.287),
        (258.216, 676.583),
        (787.127, 1634.3),
        (1757.82, 2040.38),
        (2167.31, 9999999999)
    ]

    assert parse_silences(test_silences) == expected

def test_create_ffmpeg_pipeline():
    ffp = get_ffprobe(test_filename)
    audio_track = get_track(ffp, "audio", "0x103")
    pipeline = create_ffmpeg_pipeline(test_filename, audio_track, parse_silences(test_silences))
    expected = [
        '-i', test_filename,
        '-filter_complex',
        '[0:v]trim=end=7.16406:setpts=PTS-STARTPTS:start=0[s0];[0:3]atrim=asetpts=PTS-STARTPTS:end=7.16406:start=0[s1];[0:v]trim=end=102.287:setpts=PTS-STARTPTS:start=7.16406[s2];[0:3]atrim=asetpts=PTS-STARTPTS:end=102.287:start=7.16406[s3];[0:v]trim=end=676.583:setpts=PTS-STARTPTS:start=258.216[s4];[0:3]atrim=asetpts=PTS-STARTPTS:end=676.583:start=258.216[s5];[0:v]trim=end=1634.3:setpts=PTS-STARTPTS:start=787.127[s6];[0:3]atrim=asetpts=PTS-STARTPTS:end=1634.3:start=787.127[s7];[0:v]trim=end=2040.38:setpts=PTS-STARTPTS:start=1757.82[s8];[0:3]atrim=asetpts=PTS-STARTPTS:end=2040.38:start=1757.82[s9];[0:v]trim=end=9999999999:setpts=PTS-STARTPTS:start=2167.31[s10];[0:3]atrim=asetpts=PTS-STARTPTS:end=9999999999:start=2167.31[s11];[s0][s1][s2][s3][s4][s5][s6][s7][s8][s9][s10][s11]concat=a=1:n=6:v=1[s12]',
        '-map', '[s12]',
        '/tmp/output.mp4'
    ]

    assert ffmpeg.get_args(pipeline.output("/tmp/output.mp4")) == expected
    
# The actual code
def get_track(ffprobe_info, track_type, track_id=None):
    for track in ffprobe_info['streams']:
        if track['codec_type'] == track_type:
            if track_id is None or track['id']== track_id:
                    return track

def get_ffprobe(filename):
    return ffmpeg.probe(filename)


def detect_silences(filename, audio_track):
    """
    Returns the list of ranges which are not silent in the given audio track
    """
    index = audio_track['index']
    cache_fn = "{}.silence".format(filename)
    if os.path.exists(cache_fn):
        with open(cache_fn, 'rb') as f:
            text = f.read()
    else:
        input = ffmpeg.input(filename)
        streamspec = (
            input
            .filter("silencedetect", n="-50dB", d=5)
            .output("-", vn=None, f="null")
        )
        out, text = streamspec.run(capture_stdout=True, capture_stderr=True)
        with open(cache_fn, "wb") as f:
            f.write(text)

    print(text.decode('UTF-8').split('\n'))
    
    silence_list = [x for x in text.decode('UTF-8').split('\n') if '[silencedetect' in x]

    # ['[silencedetect @ 0x1417fc0] silence_start: 0', '[silencedetect @ 0x1417fc0] silence_end: 7.16406 | silence_duration: 7.16406']

    return parse_silences(silence_list)


def create_ffmpeg_pipeline(input_filename, audio_track, ranges):
    input = ffmpeg.input(input_filename)

    if os.getenv("NOVIDEO"):
        video = False
    else:
        video = True
    
    filter_ranges = []
    
    for r in ranges:
        if video:
            filter_ranges.append(
                ffmpeg.setpts(input['v'].filter("trim", start=r[0], end=r[1]), "PTS-STARTPTS")
            )
        filter_ranges.append(
            ffmpeg.filter(
                input[str(audio_track['index'])].filter("atrim", start=r[0], end=r[1]),
                "asetpts",
                "PTS-STARTPTS"
            )
        )

    joined = ffmpeg.concat(*filter_ranges, v=1 if video else 0, a=1)
    return joined


def add_padding(filter_chain, duration):
    if os.getenv("NOVIDEO"):
        return filter_chain
    else:
        return filter_chain.filter("tpad", stop_mode="clone", stop_duration=duration + random.randint(0, 1800))

def parse_silences(lines):
    """
    This function returns the inverse of the silences. That is, all ranges which are not silent.
    """

    ranges = []
    silence_start = None
    silence_end = None
    
    for line in lines:
        line = line.strip()
        m = re.search("silence_start: ([^ ]*)", line)
        if m:
            silence_start = m.group(1)

            if silence_end:
               ranges.append((float(silence_end), float(silence_start)))

        m = re.search("silence_end: ([^ ]*)", line)
        if m:
            silence_end = m.group(1)

    if silence_end:
        ranges.append((float(silence_end), 9999999999))

    if not ranges:
        ranges.append((0, 9999999999))

    if float(ranges[0][0]) > 2:
        ranges.insert(0, (0, ranges[0][0]))

    return ranges

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="the filename to transcode")
    parser.add_argument("--debug", help="enable debug output", action="store_true")
    parser.add_argument("--audiotrack", help="the audio track to output", default="0x103")
    parser.add_argument("--tv-audiotrack", help="tv audiotrack to detect silences from", default="0x101")

    args = parser.parse_args()
    
    if os.getenv("NOVIDEO"):
        video = False
    else:
        video = True

    audiotrack = args.audiotrack
    if audiotrack == 'tv':
        audiotrack = '0x101'
    elif audiotrack == 'radio':
        audiotrack = '0x103'
    
    # Run ffprobe
    ffp = get_ffprobe(args.filename)
    # Get the audio track with the tv sound
    tv_aud_track = get_track(ffp, "audio", args.tv_audiotrack)

    if not tv_aud_track:
        # If no track could be found, fall back to the first one
        tv_aud_track = get_track(ffp, "audio", None)

    radio_aud_track = get_track(ffp, "audio", audiotrack)
    if not radio_aud_track:
        # If no track could be found, fall back to the first one
        radio_aud_track = get_track(ffp, "audio", None)

    # Get the silence ranges
    print("Detecting silences")
    silences = detect_silences(args.filename, tv_aud_track)    

    print("Silences: {}".format(silences))
    print("Creating pipeline")
    pipeline = create_ffmpeg_pipeline(args.filename, radio_aud_track, silences)
    # Add some random padding
    padded_pipeline = add_padding(pipeline, int(float(ffp['format']['duration'])))

    output_filename = "media/{}-{}{}.mp4".format(os.path.splitext(args.filename)[0], radio_aud_track['index'], "" if video else "-audio")
    
    output = padded_pipeline.output(output_filename, preset="veryfast")
    print("Output pipeline: ")
    print(ffmpeg.get_args(output))
    print("Transcoding...")
    output.run()

if __name__ == '__main__':
    main()
