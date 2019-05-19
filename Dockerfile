#FROM jrottenberg/ffmpeg:4.0-ubuntu
#FROM jrottenberg/ffmpeg:4.0
FROM mattiasa/ffmpeg:snapshot-ubuntu

RUN apt-get update && apt-get install -y software-properties-common && apt-get clean

RUN add-apt-repository -y ppa:deadsnakes/ppa

RUN apt-get update && apt-get install -y curl wget unzip make gcc libssl-dev libconfig-dev libcurl4-openssl-dev rtmpdump python3.7 python3.7-dev libyaml-dev libffi-dev software-properties-common && apt-get clean

RUN wget https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip && unzip setuptools* && cd setuptools* && python3.7 setup.py install && cd .. && rm -rf setuptools*

RUN curl https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz | tar xvfz - && cd pip-* && python3.7 setup.py install && cd .. && rm -rf pip-*

RUN pip3.7 install feedgen

RUN pip3.7 install --upgrade pip

#RUN pip3.7 install streamlink


RUN pip3.7 install raccoon==2.1.5


RUN pip3.7 install win-inet-pton
RUN pip3.7 install https://github.com/mattiasa/streamlink/archive/0.13.90.zip

#RUN wget https://github.com/mattiasa/mlbviewer/archive/master.zip && unzip master.zip && mv mlbviewer-master /mlbviewer
RUN pip3.7 install requests_toolbelt

RUN apt-get update && apt-get install -y git locales && apt-get clean

# streamglob
# RUN pip3 install git+https://github.com/tonycpsu/streamglob.git

# mlbstreamer
ADD src /src
RUN (cd /src/mlbstreamer && python3.7 setup.py install)

#RUN wget -O mlbstream.zip https://github.com/tonycpsu/mlbstreamer/archive/bb3caabcfda036e646415edb73a5b3270075a24e.zip && unzip mlbstream.zip && cd mlbstreamer-* && python3.7 setup.py install

ADD scripts/* /usr/local/bin/

RUN pip3.7 install pymediainfo

ENV LANG=en_US.utf-8
ENV LC_ALL=en_US.utf-8

WORKDIR /

ENTRYPOINT []
