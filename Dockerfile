FROM jrottenberg/ffmpeg:3.3

RUN apt-get update && apt-get install -y wget unzip make gcc libssl-dev libconfig-dev libcurl4-openssl-dev python python-pip rtmpdump && apt-get clean

RUN pip install feedgen

RUN wget https://github.com/mattiasa/mlbtv-hls-nexdef/archive/mattiasa-retry.zip
RUN unzip mattiasa-retry.zip
RUN (cd mlbtv-hls-nexdef-mattiasa-retry && make && cp mlbhls /usr/local/bin/)

RUN wget https://github.com/mattiasa/mlbviewer/archive/master.zip && unzip master.zip && mv mlbviewer-master /mlbviewer


#RUN apt-get update && apt-get install -y && apt-get clean

ADD scripts/* /usr/local/bin/

WORKDIR /

ENTRYPOINT []
