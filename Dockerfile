#FROM jrottenberg/ffmpeg:4.0-ubuntu
#FROM jrottenberg/ffmpeg:4.0
FROM mattiasa/ffmpeg:snapshot-ubuntu


RUN apt-get update && apt-get install -y software-properties-common && apt-get clean

RUN add-apt-repository -y ppa:deadsnakes/ppa

RUN apt-get update && \
    apt-get install -y \
      curl \
      gcc \
      git \
      graphviz \
      libconfig-dev \
      libcurl4-openssl-dev \
      libffi-dev \
      libssl-dev \
      libyaml-dev \
      locales \
      mediainfo \
      make \
      python3.7 \
      python3.7-dev \
      software-properties-common \
      rtmpdump \
      unzip \
      wget \
      && \
    apt-get clean

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN locale-gen $LANG

RUN wget https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip && \
    unzip setuptools* && \
    cd setuptools* && \
    python3.7 setup.py install && \
    cd .. && \
    rm -rf setuptools*

RUN curl https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz | tar xvfz - && \
    cd pip-* && \
    python3.7 setup.py install && \
    cd .. && \
    rm -rf pip-*

RUN pip3.7 install --upgrade pip

ADD requirements.pip /
RUN pip3.7 install -r /requirements.pip

#RUN wget https://github.com/mattiasa/mlbviewer/archive/master.zip && unzip master.zip && mv mlbviewer-master /mlbviewer

# mlbstreamer
ADD src /src
RUN (cd /src/mlbstreamer && python3.7 setup.py install)

ADD requirements-dev.pip /
RUN pip3.7 install -r /requirements-dev.pip

ADD scripts/* /usr/local/bin/

WORKDIR /

ENTRYPOINT []
