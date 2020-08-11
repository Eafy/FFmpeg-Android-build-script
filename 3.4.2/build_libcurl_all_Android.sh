#!/bin/bash
#使用curl-7.61.1.tar.gz，脚本需要放到源码中执行

for arch in armeabi armeabi-v7a armeabi-v7a-hard arm64-v8a mips mips64 x86 x86_64
do
    bash build_libcurl_Android.sh $arch
    make
    sudo make install
done
