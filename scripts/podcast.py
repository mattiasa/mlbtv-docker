#! /usr/bin/env python

# -*- coding: utf-8 -*-

from urlparse import urlparse
from os.path import splitext, basename

from feedgen.feed import FeedGenerator
import os
from stat import ST_SIZE
import mimetypes
import urllib
from pprint import pprint
mediadir = "media"
baseurl = os.getenv("BASEURL")
mediaurl = baseurl + "media/"

fg = FeedGenerator()
fg.load_extension('podcast')

fg.podcast.itunes_category('Technology', 'Podcasting')
fg.title("Mattias Vimes MLB")
fg.logo(baseurl + "mlb_logo.jpg")
fg.link(href=baseurl + "podcast.xml")
fg.description("Mattias MLB games")

for fn in sorted(os.listdir(mediadir)):
    print "Processing %s" % fn

    if fn.endswith(".part"):
        print "Skipping"
        continue

    pprint(fn)
    abs_fn = os.path.join(mediadir, fn)

    if not os.path.isfile(abs_fn):
        print "Skipping"
        continue

    mimetype = mimetypes.guess_type(abs_fn)
    fn_stat = os.stat(abs_fn)
    if not mimetype[0]:
        print "Could not guess mimetype for %s" % abs_fn
        exit(1)

#    mediainfo = MediaInfo.parse(abs_fn)
#    for track in mediainfo.tracks:
#        if track.track_type == "General":
#            print track.duration
#    print json.loads(mediainfo.to_json())['tracks'][0].keys()

    url = mediaurl + urllib.pathname2url(fn)

    unicode_fn = unicode(fn, 'latin-1')

    fe = fg.add_entry()
    fe.id(url)
    fe.title(unicode_fn)
    fe.description(unicode_fn)
    fe.enclosure(url, "%d" % fn_stat[ST_SIZE], mimetype[0])
    fe.link(href=url)
    fg.rss_file('/tmp/foo.xml', pretty=True)

fg.rss_str(pretty=True)
fg.rss_file('podcast.xml', pretty=True)
