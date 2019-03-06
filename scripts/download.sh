#! /bin/bash -e

TMPDIR=$(mktemp -d tmpdir.XXXXXX)

mlbplay -s "$TMPDIR" $@
TSFILE=$(cd "$TMPDIR" && ls *.ts)
mv "$TMPDIR/$TSFILE" .
rm -rf "$TMPDIR"

/usr/local/bin/transcode.sh "$TSFILE"

podcast.py
