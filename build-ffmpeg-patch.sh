#!/bin/bash

FF_PATH=$1
SHELL_PATH=`pwd`

set -x
patch  -p0 -N --dry-run --silent -f $FF_PATH/libavcodec/aaccoder.c < $SHELL_PATH/ffmpeg_modify_aacoder.patch 1>/dev/null
if [ $? -eq 0 ]; then
patch -p0 -f $FF_PATH/libavcodec/aaccoder.c < $SHELL_PATH/ffmpeg_modify_aacoder.patch
fi

patch  -p0 -N --dry-run --silent -f $FF_PATH/libavcodec/hevc_mvs.c < $SHELL_PATH/ffmpeg_modify_hevc_mvs.patch 1>/dev/null
if [ $? -eq 0 ]; then
patch -p0 -f $FF_PATH/libavcodec/hevc_mvs.c < $SHELL_PATH/ffmpeg_modify_hevc_mvs.patch
fi

patch  -p0 -N --dry-run --silent -f $FF_PATH/libavcodec/opus_pvq.c < $SHELL_PATH/ffmpeg_modify_opus_pvq.patch 1>/dev/null
if [ $? -eq 0 ]; then
patch -p0 -f $FF_PATH/libavcodec/opus_pvq.c < $SHELL_PATH/ffmpeg_modify_opus_pvq.patch
fi

patch  -p0 -N --dry-run --silent -f $FF_PATH/configure < $SHELL_PATH/ffmpeg_modify_configure.patch 1>/dev/null
if [ $? -eq 0 ]; then
patch -p0 -f $FF_PATH/configure < $SHELL_PATH/ffmpeg_modify_configure.patch
fi
set +x


