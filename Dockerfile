FROM jrottenberg/ffmpeg:snapshot-ubuntu
#FROM jrottenberg/ffmpeg:4.0
#FROM ffmpeg:snapshot

RUN apt-get update && apt-get install -y curl wget unzip make gcc libssl-dev libconfig-dev libcurl4-openssl-dev python python-pip rtmpdump libyaml-dev libffi-dev && apt-get clean

RUN pip install feedgen

RUN pip install --upgrade pip

#RUN pip install streamlink


RUN pip install raccoon==2.1.5

RUN wget https://github.com/tonycpsu/mlbstreamer/archive/v0.0.10.zip && unzip v0.0.10.zip
RUN cd mlbstreamer-* && python setup.py install

RUN pip install win-inet-pton
RUN pip install https://github.com/mattiasa/streamlink/archive/0.13.90.zip

#RUN wget https://github.com/mattiasa/mlbviewer/archive/master.zip && unzip master.zip && mv mlbviewer-master /mlbviewer


#RUN apt-get update && apt-get install -y && apt-get clean

ADD scripts/* /usr/local/bin/

WORKDIR /

ENTRYPOINT []
