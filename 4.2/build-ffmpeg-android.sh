#!/bin/bash

#···············支持的平台·第三方库·Andoird API·NDK路径
#./build-ffmpeg-android.sh all all yes 21 /Users/lzj/Library/Android/sdk/ndk-bundle

#需要编译FFpmeg版本号
FF_VERSION="4.2"
SOURCE="ffmpeg-$FF_VERSION"
SHELL_PATH=`pwd`
FF_PATH=$SHELL_PATH/$SOURCE
#输出路径
PREFIX=$SHELL_PATH/ffmpeg-android
#需要编译的平台
COMP_BUILD=$1
#是否重新编译其他库
COMP_OTHER=$2
#是否重新编译第三方库
BUILD_THIRD_LIB_COMPILE=$3
#API版本
ANDROID_API=$4
#NDK版本
NDK=$5

#需要编译的NDK路径，NDK版本需大等于r15c
if [ ! "$NDK" ]
then
NDK=/Users/lzj/Library/Android/sdk/ndk-bundle
fi
#需要编译的Android API版本
if [ ! "$ANDROID_API" ]
then
ANDROID_API=21
fi
if [ ! "$COMP_OTHER" ]
then
COMP_OTHER="all"
fi
if [ ! "$COMP_BUILD" ]
then
COMP_BUILD="all"
fi
if [ ! "$BUILD_THIRD_LIB_COMPILE" ]
then
BUILD_THIRD_LIB_COMPILE="yes"
fi

#x264库路径
if [ "$COMP_OTHER" = "x264" ] || [ "$COMP_OTHER" = "all" ]
then
    x264=$SHELL_PATH/x264-android
    if [ "$BUILD_THIRD_LIB_COMPILE" = "yes" ]    #是否重新编译x264的库
    then
        if [ "$x264" ] && [[ $FF_VERSION == 3.0.* ]] || [[ $FF_VERSION == 3.1.* ]]
        then
            echo "Use low version x264"
            sh $SHELL_PATH/build-x264-android.sh $COMP_BUILD low $ANDROID_API $NDK
        elif [ "$x264" ]
        then
            echo "Use last version x264"
        sh $SHELL_PATH/build-x264-android.sh $COMP_BUILD last $ANDROID_API $NDK
        fi
    fi
fi

#OpenSSL库路径,需要手动下载openssl源码包
if [ "$COMP_OTHER" = "openssl" ] || [ "$COMP_OTHER" = "all" ]
then
OpenSSL=$SHELL_PATH/openssl-android
    if [ "$BUILD_THIRD_LIB_COMPILE" = "yes" ]    #是否重新编译x264的库
    then
        sh $SHELL_PATH/build-openssl-android.sh $COMP_BUILD $ANDROID_API $NDK
    fi
fi

#是否编译opencore-amr
OPENCORE_AMR=$SHELL_PATH/opencore-amr-android

#需要编译的平台:arm arm64 x86 x86_64，可传入平台单独编译对应的库
ARCHS=(arm arm64 x86 x86_64)
TRIPLES=(arm-linux-androideabi aarch64-linux-android i686-linux-android x86_64-linux-android)
TRIPLES_PATH=(arm-linux-androideabi-4.9 aarch64-linux-android-4.9 x86-4.9 x86_64-4.9)

FF_CONFIGURE_FLAGS="--enable-static --disable-shared --disable-indevs --disable-outdevs --enable-pic --enable-nonfree --enable-gpl --disable-stripping --enable-small --enable-version3 --enable-jni --enable-pthreads --enable-mediacodec --enable-hwaccels --enable-postproc"

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-encoders --disable-decoders \
--disable-muxers --disable-parsers --disable-filters \
--enable-encoder=h264,aac,libx264,pcm_*,*jpeg* \
--enable-decoder=h264,aac,pcm*,*jpeg*,amr*,hevc,h264_mediacodec,hevc_mediacodec,mpeg4_mediacodec,vp8_mediacodec,vp9_mediacodec \
--enable-muxer=h264,aac,pcm*,flv,mp4,avi,mp3,amr \
--enable-parser=h264,aac,hevc,mpeg4video,*jpeg*,mpeg* \
--enable-avfilter --enable-filter=anull"
#--disable-demuxers --enable-demuxer=h264,aac,hevc,pcm*,flv,hls,mp3,avi,hls,amr*,mpeg* \

#rm -rf "$PREFIX"
#rm -rf "$SOURCE"
if [ ! -r $SOURCE ]
then
    if [ ! -f "$SOURCE.tar.bz2" ]
    then
        echo "$SOURCE source not found, Trying to download..."
        curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj || exit 1
    else
        mkdir $FF_PATH
        tar zxvf $SHELL_PATH/"$SOURCE.tar.bz2" --strip-components 1 -C $FF_PATH || exit 1
    fi
fi

#若使用android-ndk-r15c及以上NDK需要打此补丁(修改FFmepg与NDK代码冲突)
sh $SHELL_PATH/build-ffmpeg-patch.sh $FF_PATH

cd $FF_PATH
export TMPDIR=$FF_PATH/tmpdir
mkdir $TMPDIR
for i in "${!ARCHS[@]}";
do
    ARCH=${ARCHS[$i]}
    TOOLCHAIN=$NDK/toolchains/${TRIPLES_PATH[$i]}/prebuilt/darwin-x86_64
    SYSROOT=$NDK/platforms/android-$ANDROID_API/arch-$ARCH/
    ISYSROOT=$NDK/sysroot
    ASM=$ISYSROOT/usr/include/${TRIPLES[$i]}
    CROSS_PREFIX=$TOOLCHAIN/bin/${TRIPLES[$i]}-
    PREFIX_ARCH=$PREFIX/$ARCH

    if [ "$COMP_BUILD" = "all" -o "$COMP_BUILD" = "$ARCH" ]
    then
        TRMP_P=""
        if [ "$ARCH" = "arm" ]
        then
            FF_EXTRA_CONFIGURE_FLAGS="--disable-asm"
            FF_EXTRA_CFLAGS="-fpic -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300"
            TRMP_P="eabi-v7a"
            PREFIX_ARCH="$PREFIX_ARCH$TRMP_P"
        elif [ "$ARCH" = "arm64" ]
        then
            if [ $ANDROID_API -lt 21 ]
            then
                continue
            else
            FF_EXTRA_CONFIGURE_FLAGS=""
            FF_EXTRA_CFLAGS="-fpic"
            TRMP_P="-v8a"
            PREFIX_ARCH="$PREFIX_ARCH$TRMP_P"
            fi
        elif [ "$ARCH" = "x86" -o "$ARCH" = "x86_64" ]
        then
            if [ "$ARCH" = "x86_64" -a $ANDROID_API -lt 21 ]
            then
                continue
            else
                FF_EXTRA_CONFIGURE_FLAGS="--disable-asm"
                FF_EXTRA_CFLAGS="-fpic -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -fomit-frame-pointer -march=k8"
            fi
        else
            echo "Unrecognized arch:$ARCH"
            exit 1
        fi

        if [ "$x264" ]
        then
            FF_EXTRA_CONFIGURE_FLAGS="$FF_EXTRA_CONFIGURE_FLAGS --enable-libx264 --enable-encoder=libx264"
            FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -I$x264/${ARCHS[$i]}$TRMP_P/include"
            FF_LDFLAGS="$FF_LDFLAGS -L$x264/${ARCHS[$i]}$TRMP_P/lib"
        fi

        if [ "$OpenSSL" ]
        then
            export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${OpenSSL}/${ARCHS[$i]}$TRMP_P/lib/pkgconfig
            FF_EXTRA_CONFIGURE_FLAGS="$FF_EXTRA_CONFIGURE_FLAGS --enable-openssl --pkg-config=pkg-config"
#            FF_EXTRA_CONFIGURE_FLAGS="$FF_EXTRA_CONFIGURE_FLAGS --enable-openssl"
            FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -I$OpenSSL/${ARCHS[$i]}$TRMP_P/include"
            FF_LDFLAGS="$FF_LDFLAGS -L$OpenSSL/${ARCHS[$i]}$TRMP_P/lib"
        fi
        
        if [ "$OPENCORE_AMR" ]
        then
            FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -I$OPENCORE_AMR/${ARCHS[$i]}$TRMP_P/include"
            FF_LDFLAGS="$FF_LDFLAGS -L$OPENCORE_AMR/${ARCHS[$i]}$TRMP_P/lib"
            FF_EXTRA_CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-encoder=libopencore_amrnb"
        fi
    else
        continue
    fi
    FF_CFLAGS="-I$ASM -isysroot $ISYSROOT -D__ANDROID_API__=$ANDROID_API -U_FILE_OFFSET_BITS -O3 -pipe -Wall -ffast-math -fstrict-aliasing -Werror=strict-aliasing -Wno-psabi -Wa,--noexecstack -DANDROID"

    echo FF_EXTRA_CFLAGS=$FF_EXTRA_CFLAGS
    echo FF_LDFLAGS=$FF_LDFLAGS
    echo FF_CONFIGURE_FLAGS=$FF_CONFIGURE_FLAGS
    echo FF_EXTRA_CONFIGURE_FLAGS=$FF_EXTRA_CONFIGURE_FLAGS

    ./configure \
    --prefix=$PREFIX_ARCH \
    --sysroot=$SYSROOT \
    --target-os=android \
    --arch=$ARCH \
    --cross-prefix=$CROSS_PREFIX \
    --enable-cross-compile \
    --disable-runtime-cpudetect \
    --disable-doc \
    --disable-debug \
    --disable-ffmpeg \
    --disable-ffprobe \
    --disable-programs \
    --disable-ffplay \
    $FF_CONFIGURE_FLAGS \
    $FF_EXTRA_CONFIGURE_FLAGS \
    --extra-cflags="$FF_EXTRA_CFLAGS $FF_CFLAGS" \
    --extra-ldflags="$FF_LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG || exit 1
    make -j3 install || exit 1
    make distclean
    rm -rf "$PREFIX_ARCH/share"
    rm -rf "$PREFIX_ARCH/lib/pkgconfig"
done

echo "Android FFmpeg bulid success!"


