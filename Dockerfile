FROM jrottenberg/ffmpeg:3.3

RUN apt-get update && apt-get install -y wget unzip make gcc libssl-dev libconfig-dev libcurl4-openssl-dev python && apt-get clean

RUN wget https://github.com/mattiasa/mlbtv-hls-nexdef/archive/experimental.zip

RUN unzip experimental.zip

RUN wget https://github.com/mattiasa/mlbviewer/archive/master.zip && unzip -d / master.zip


#RUN apt-get update && apt-get install -y && apt-get clean

RUN (cd mlbtv-hls-nexdef-experimental && make && cp mlbhls /usr/local/bin/)

ENTRYPOINT []
