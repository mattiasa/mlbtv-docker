#! /bin/bash -e

TMPDIR=$(mktemp -d tmpdir.XXXXXX)

mlbplay -s "$TMPDIR" $@
TSFILE=$(cd "$TMPDIR" && ls *.ts)
mv "$TMPDIR/$TSFILE" .
rm -rf "$TMPDIR"

transcode.py "$TSFILE"

podcast.py
