MLB.TV Downloader
=================

This is a docker image which can be used to download and transcode a
game from mlb.tv to a format suitable to watch on for example an ipad.

I use it to create an mp4 with the video from the TV video stream and
the radio audio stream.

The scripts also detects any silence longer than 5 seconds in the TV
audio feed and cuts that section out from both the video and the
audio. This removes the commercial breaks since they are silent in the
TV audio stream.

For locally broadcast games, both the home and away audio streams are
available and the script will select the one for the team given on the
command line. For nationally broadcast games only the home radio feed
is available.

Podcast feed
------------

If you have a webserver set up to point to the video directory then
you can access the file podcast.xml with a podcast app capable of
displaying video. Personally, I use this with a cron job to download
games over night to have them freshly available in my phone when I
wake up in the morning.

The base url to the podcast file can be modified with the BASEURL
environment variable in `docker-compose.yml`.

Requirements
------------

* docker
* docker-compose

Running
-------

Build the image with 

```
docker-compose build
```

Then run it with:

```
docker-compose run --rm mlbtv /mlbviewer/mlbplay.py v=chc
```

This will create an mp4 file in the `videos` directory.
