#!/bin/bash

FF_PATH=$1
SHELL_PATH=`pwd`

patch  -p0 -N --dry-run --silent -f $FF_PATH/configure < $SHELL_PATH/ffmpeg_modify_configure_to_gcc.patch 1>/dev/null
if [ $? -eq 0 ]; then
patch -p0 -f $FF_PATH/configure < $SHELL_PATH/ffmpeg_modify_configure_to_gcc.patch
fi
set +x


