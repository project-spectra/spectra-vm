#!/bin/bash

TOOLCHAIN_ROOT=/root/ndk-bundle-r19c/android-toolchain
ANDROID_API_VERSION=24

# build OpenBLAS first
TOOLCHAIN_R19_GFORTRAN_ENABLED=/root/android-toolchain-standalone-r19-gfortran/aarch64-linux-android-4.9

_SYSROOT="/root/ndk-bundle-r19c/platforms/android-24/arch-arm64"
_C_FLAGS="--sysroot=$_SYSROOT -I$TOOLCHAIN_ROOT/sysroot/usr/include -I$TOOLCHAIN_ROOT/sysroot/usr/include/aarch64-linux-android -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"
_CPP_FLAGS="--sysroot=$_SYSROOT -I$TOOLCHAIN_ROOT/sysroot/usr/include -I$TOOLCHAIN_ROOT/sysroot/usr/include/aarch64-linux-android -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"
_LDFLAGS="--sysroot=$_SYSROOT -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"

# include armadillo into the build process
wget https://sources.voidlinux.org/armadillo-9.200.8/armadillo-9.200.8.tar.xz
tar -xf armadillo-9.200.8.tar.xz && mv armadillo-9.200.8 armadillo
rm armadillo-9.200.8.tar.xz

mkdir -p build-android-arm64
cd build-android-arm64

# export LD_LIBRARY_PATH=`pwd`/OpenBLAS/build/lib:/home/transfusion/Android/Sdk/ndk-bundle/android-toolchain/sysroot/usr/lib/aarch64-linux-android/24:$LD_LIBRARY_PATH
# export BLAS=`pwd`/OpenBLAS/build/libopenblas.a
# export ATLAS=`pwd`/OpenBLAS/build/lib/libopenblas.a

TOOLCHAIN_R19_GFORTRAN_ENABLED=$TOOLCHAIN_R19_GFORTRAN_ENABLED cmake -DCMAKE_C_COMPILER=$TOOLCHAIN_ROOT/bin/aarch64-linux-android$ANDROID_API_VERSION-clang \
      -DCMAKE_CXX_COMPILER=$TOOLCHAIN_ROOT/bin/aarch64-linux-android$ANDROID_API_VERSION-clang++ \
      -DCMAKE_Fortran_COMPILER=$TOOLCHAIN_R19_GFORTRAN_ENABLED/bin/aarch64-linux-android-gfortran \
      -DCMAKE_COLOR_MAKEFILE=1 \
      -DTARGET_ARCH=Android_ARM64 \
      -DCMAKE_BUILD_TYPE=$1 \
      -DBUILD_SHARED_LIBS=OFF \
      -DDETECT_HDF5=FALSE \
      -DARMA_DONT_USE_WRAPPER=TRUE \
      -DCMAKE_INCLUDE_PATH="/root/OpenBLAS/build/include" \
      -DCMAKE_LIBRARY_PATH="/root/OpenBLAS/build/lib;$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/$ANDROID_API_VERSION;$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib;$TOOLCHAIN_R19_GFORTRAN_ENABLED/aarch64-linux-android/lib;$TOOLCHAIN_R19_GFORTRAN_ENABLED/aarch64-linux-android/lib64" ..

make -j$(nproc)

cp /root/android-toolchain-standalone-r19-gfortran/aarch64-linux-android-4.9/aarch64-linux-android/lib64/libgfortran.so /root/glottal-inverse/bin
cp /root/OpenBLAS/build/lib/libopenblas.so /root/glottal-inverse/bin