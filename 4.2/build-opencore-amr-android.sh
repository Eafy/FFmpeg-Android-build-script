#!/bin/sh
#https://downloads.sourceforge.net/project/opencore-amr/opencore-amr

set -xe

VERSION="0.1.5"
LIBSRCNAME="opencore-amr"
CURRENTPATH=`pwd`
SRC_PATH=$CURRENTPATH/$LIBSRCNAME-$VERSION
LIBS="libopencore-amrnb.a libopencore-amrwb.a"

#输出路径
PREFIX=$CURRENTPATH/opencore-amr-android
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
NDK=/Users/lzj/Library/Android/sdk/ndk/21.3.6528147
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

rm -rf "${CURRENTPATH}/${LIBSRCNAME}-${VERSION}"
rm -rf "$PREFIX"
tar zxvf ${LIBSRCNAME}-${VERSION}.tar.gz -C "${CURRENTPATH}"
cd "${CURRENTPATH}/${LIBSRCNAME}-${VERSION}"

for i in "${!ARCHS[@]}";
do
    TRMP_P=""
    if [ "$COMP_BUILD" = "all" -o "$COMP_BUILD" = "${ARCHS[$i]}" ]
        then
        if [ "${ARCHS[$i]}" = "arm" ]
        then
            TRMP_P="eabi-v7a"
        elif [ "${ARCHS[$i]}" = "arm64" ]
        then
            TRMP_P="-v8a"
        fi
    else
        continue
    fi
    
    ARCH=${ARCHS[$i]}
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
    SYSROOT=$NDK/platforms/android-$ANDROID_API/arch-$ARCH/
    ISYSROOT=$NDK/sysroot
    ASM=$ISYSROOT/usr/include/${TRIPLES[$i]}
    CROSS_PREFIX=$TOOLCHAIN/bin/${TRIPLES[$i]}
    PREFIX_ARCH=$PREFIX/$ARCH$TRMP_P
    
    CFLAGS="-I$ASM -isysroot $ISYSROOT -D__ANDROID_API__=$ANDROID_API -U_FILE_OFFSET_BITS -DANDROID -fPIC"
    LDFLAGS="-L$NDK/sysroot/user/${TRIPLES_PATH[$i]} -L$SYSROOT/usr/lib"

#    CFLAGS="-I${ISYSROOT}/usr/include -I$ASM" RANLIB=${CROSS_PREFIX}-ranlib CC=${CROSS_PREFIX}-gcc CXX=${CROSS_PREFIX}-g++ LD=${CROSS_PREFIX}-ld CPP=${CROSS_PREFIX}-cpp LDFLAGS="-L${SYSROOT}usr/lib/ -fPIC -nostdlib -I${ISYSROOT}/usr/include -I$ASM" .
    
    /configure \
    --host=${TRIPLES[$i]} \
    --disable-shared \
    --with-sysroot=${SYSROOT}
    
    
    make -j3 || exit
    make install || exit
    
done

#for i in $LIBS; do
#    input=""
#    for arch in $ARCHS; do
#        input="$input $DEST/lib/$i.$arch"
#    done
#    xcrun lipo -create -output $DEST/lib/$i $input
#done
