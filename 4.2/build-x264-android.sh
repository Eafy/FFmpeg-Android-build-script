#!/bin/bash

X264_VERSION=""
SOURCE="x264"
SHELL_PATH=`pwd`
X264_PATH=$SHELL_PATH/$SOURCE
#输出路径
PREFIX=$SHELL_PATH/x264_android
COMP_BUILD=$1
LAST_VERSION=$2
ANDROID_API=$3
NDK=$4

if [ ! "$COMP_BUILD" ]
then
COMP_BUILD="all"
fi
#需要编译的Android API版本
if [ ! "$ANDROID_API" ]
then
ANDROID_API=21
fi
#需要编译的NDK路径，NDK版本需大等于r15c
if [ ! "$NDK" ]
then
NDK=/Users/lzj/Library/Android/sdk/ndk-bundle
fi
if [ ! "$LAST_VERSION" ]
then
LAST_VERSION=last
fi
echo COMP_BUILD=$COMP_BUILD
echo LAST_VERSION=$LAST_VERSION
echo ANDROID_API=$ANDROID_API
echo NDK=$NDK

#需要编译的平台:arm arm64 x86 x86_64
ARCHS=(arm arm64 x86 x86_64)
TRIPLES=(arm-linux-androideabi aarch64-linux-android i686-linux-android x86_64-linux-android)
TRIPLES_PATH=(arm-linux-androideabi-4.9 aarch64-linux-android-4.9 x86-4.9 x86_64-4.9)

FF_FLAGS="--enable-static --enable-pic --disable-cli"
#FF_FLAGS="--enable-shared --enable-pic --disable-cli"

rm -rf "$PREFIX"
#rm -rf "$SOURCE"
if [ ! -r $SOURCE ]
then
    if [ "$LAST_VERSION" ] && [ $ANDROID_API -ge 21 ]
    then
        X264_TAR_NAME="x264-snapshot-20180630-2245.tar.bz2"
    else
        X264_TAR_NAME="x264-snapshot-20160114-2245.tar.bz2"
    fi
    if [ ! -f "$SHELL_PATH/$X264_TAR_NAME" ]
    then
        echo "$X264_TAR_NAME source not found, Trying to download..."
        curl -O http://download.videolan.org/pub/videolan/x264/snapshots/$X264_TAR_NAME
    fi
    mkdir $X264_PATH
    tar zxvf $SHELL_PATH/$X264_TAR_NAME --strip-components 1 -C $X264_PATH || exit 1
fi

cd $X264_PATH
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
        if [ "$ARCH" = "arm" ]
        then
            TRMP_P="eabi-v7a"
            PREFIX_ARCH="$PREFIX_ARCH$TRMP_P"
            FF_CONFIGURE_FLAGS="$FF_FLAGS --disable-asm"
        elif [ "$ARCH" = "arm64" ]
        then
            if [ $ANDROID_API -lt 21 ]
            then
                continue
            else
                TRMP_P="-v8a"
                PREFIX_ARCH="$PREFIX_ARCH$TRMP_P"
                FF_CONFIGURE_FLAGS="$FF_FLAGS"
            fi
        elif [ "$ARCH" = "x86_64" -a $ANDROID_API -lt 21 ]
        then
            continue
        else
            FF_CONFIGURE_FLAGS="$FF_FLAGS --disable-asm"
        fi
    else
        continue
    fi

    FF_CFLAGS="-I$ASM -isysroot $ISYSROOT -D__ANDROID_API__=$ANDROID_API -U_FILE_OFFSET_BITS -DANDROID -fPIC"

    ./configure \
    --prefix=$PREFIX_ARCH \
    --sysroot=$SYSROOT \
    --host=${TRIPLES[$i]} \
    --cross-prefix=$CROSS_PREFIX \
    $FF_CONFIGURE_FLAGS \
    --extra-cflags="$FF_CFLAGS" \
    --extra-ldflags="" \
    $ADDITIONAL_CONFIGURE_FLAG || exit 1
    make -j3 install || exit 1
    make distclean
    if [[ $FF_CONFIGURE_FLAGS == *--enable-shared* ]]
    then
        mv $PREFIX_ARCH/lib/libx264.so.* $PREFIX_ARCH/lib/libx264.so
    fi
done

echo "Android x264 bulid success!"


