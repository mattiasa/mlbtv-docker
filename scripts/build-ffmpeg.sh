#!/bin/bash

# Fetch Sources

#set -e
mkdir -p /usr/local/src
cd /usr/local/src

git clone --depth 1 https://github.com/l-smash/l-smash
git clone http://git.videolan.org/git/x264.git
hg clone https://bitbucket.org/multicoreware/x265
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
git clone http://source.ffmpeg.org/git/ffmpeg
git clone https://git.xiph.org/opus.git
git clone --depth 1 https://github.com/mulx/aacgain.git

# Build L-SMASH

cd /usr/local/src/l-smash
./configure
make -j 4
make install

# Build libx264 (Checkout specific commit to not get broken nasm dependency)

cd /usr/local/src/x264
git checkout d32d7bf1c6923a42cbd5ac2fd540ecbb009ba681
./configure --enable-static --enable-pic --extra-ldflags=-L/usr/local/lib/  --extra-cflags=-I/usr/local/include/
make -j 4
make install

# Build libx265

cd /usr/local/src/x265/build/linux
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../../source
make -j 4
make install

# Build libfdk-aac

cd /usr/local/src/fdk-aac
autoreconf -fiv
./configure --disable-shared
make -j 4
make install

# Build libvpx

cd /usr/local/src/libvpx
./configure --disable-examples --enable-pic
make -j 4
make install

# Build libopus

cd /usr/local/src/opus
./autogen.sh
./configure --disable-shared
make -j 4
make install

# Build ffmpeg.

cd /usr/local/src/ffmpeg
git checkout release/3.4
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --extra-cflags=-I/usr/local/include/ --extra-ldflags=-L/usr/local/lib/ --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-openssl --enable-libopus
make -j 4
make install

# Build aacgain

cd /usr/local/src/aacgain/mp4v2
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure && make -k -j 4 # some commands fail but build succeeds
cd /usr/local/src/aacgain/faad2
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure && make -k -j 4 # some commands fail but build succeeds
cd /usr/local/src/aacgain
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure && make -j 4 && make install

# Remove all tmpfile
rm -rf /usr/local/src

# Remove all static libs
rm -f /usr/local/lib/*.a
rm -f /usr/local/lib/*.la
# No need for ffserver
rm -f /usr/local/bin/ffserver
