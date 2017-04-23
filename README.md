MLB.TV Downloader
=================

This is a docker image which can be used to download and transcode a game from mlb.tv to a format suitable to watch on for example an ipad.

I use it to create an mp4 with the video from the TV feed and the radio audio.

Requirements
------------

* docker
* docker-compose

Running
-------

# docker-compose build

# docker-compose run --rm mlbtv /mlbviewer/mlbplay.py v=chc
