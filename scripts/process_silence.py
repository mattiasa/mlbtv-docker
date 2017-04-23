#! /usr/bin/env python

import fileinput
import re
import sys

silence_start = None
silence_end = None

ranges = []


if len(sys.argv) < 2:
    print "usage: %s <filename> [audiotrack]"
    exit(1)

try:
    audio_channel = sys.argv[2]
except IndexError:
    audio_channel = 1

    
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        m = re.search("silence_start: ([^ ]*)", line)
        if m:
            silence_start = m.group(1)

            if silence_end:
               ranges.append((silence_end, silence_start))

        m = re.search("silence_end: ([^ ]*)", line)
        if m:
            silence_end = m.group(1)

i = 0

cmd = """ -filter_complex " """

for r in ranges:
    
    cmd +=  """[0:v]trim=%(range_start)s:%(range_end)s,setpts=PTS-STARTPTS[v%(i)s]; [0:%(audio_channel)s]atrim=%(range_start)s:%(range_end)s,asetpts=PTS-STARTPTS[a%(i)s]; """ % dict(
        range_start=r[0],
        range_end=r[1],
        audio_channel=audio_channel,
        i=i
    )
    i+=1

channel_mapping = "".join(["[v%(j)s][a%(j)s]" % dict(j=j) for j in range(0,i)  ])
#print channel_mapping
cmd += "%(channels)sconcat=n=%(i)s:v=1:a=1[out]\" " % dict(channels=channel_mapping, i=i)
# [v0][a0][v1][a1][v2][a2]concat=n=3:v=1:a=1[out]" \

cmd += """ -map "[out]" -strict -2 -b:v 1200k """

print cmd

