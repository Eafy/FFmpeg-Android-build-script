# FFmpeg-Android-build-script
Mac编译Android平台FFmpeg的脚本，兼容包含多个FFmpeg版本，支持NDK、API、版本修改，同时支持第三方库：x264、OpenSSL等； 
## 编译前工作
  - 进入对应的版本文件夹，比如*FFmpeg-Android-build-script-master/4.2
  - 修改需要运行的脚本文件权限：chmod -R 777 *.sh
## FFmpeg编译
 - 可单独修改build-ffmpeg-android.sh、build-x264-android.sh、build-openssl-android.sh文件中对应的版本号:`*_VERSION`、编译的平台:`COMP_BUILD`、API版本:`ANDROID_API`、NDK路径:`NDK`；
 - 若需要裁减或添加功能，可修改FFmpeg脚本中的参数:`FF_CONFIGURE_FLAGS`；
 - 无需单独下载编译的资源文件，脚本已支持自动化下载；
 - 若编译API 21以下的库，需要单独编译arm、arm64、x86、x86_64；若是API 21以上可一键编译；
 - NDK的版本需>=r15c;
   - 编译参数说明</br>
    ./build-ffmpeg-android.sh `Andoird平台类型` `同时编译其他库` `Android API版本` `NDK路径` </br>
    >Andoird平台类型：arm arm64 x86 x86_64</br>
      同时编译其他库：x264 openssl</br>
      Android API版本：21 or 19 or other</br>
      NDK路径：Mac电脑Android NDK所在路径</br>
   - FFmpeg一键编译(API>=21)</br>   
      `./build-ffmpeg-android.sh`
      >`#需提前修改对应文件中的NDK路径`
   - FFmpeg单平台编译</br>
   编译x86平台、API 19的所有第三方的ffmpeg库：</br>
   `./build-ffmpeg-android.sh x86 all 19 /Users/lzj/Library/Android/sdk/ndk-bundle`</br>
   编译arm64平台、API 21的所有第三方的ffmpeg库：</br>
   `./build-ffmpeg-android.sh arm64 all 21`</br>
   编译armv7平台、API 19的带x264的ffmpeg库：</br>
   `./build-ffmpeg-android.sh arm x264 19`</br>
   编译armv7平台、API 19的带openssl的ffmpeg库：</br>
   `./build-ffmpeg-android.sh arm openssl 19`</br>
>若需要单独编译x264、openssl可查看下面
## x264编译
  - x264一键编译(API>=21)</br> 
  `./build-ffmpeg-android.sh`
  - x264单平台编译</br>
   编译arm64平台、API 21的库：</br>
   `./build-x264-android.sh arm64`</br>
   编译armv7平台、API 19的库：</br>
   `./build-x264-android.sh arm low 19`</br>
## OpenSSL编译
  - openssl一键编译(API>=21)</br> 
  `./build-openssl-android.sh`
  - openssl单平台编译</br>
   编译arm64平台、API 21的库：</br>
   `./build-openssl-android.sh arm64`</br>
   编译armv7平台、API 19的库：</br>
   `./build-openssl-android.sh arm 19`</br>
