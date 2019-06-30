#!/bin/bash

# OpenBLAS takes an awfully long time to build

TOOLCHAIN_ROOT=/root/ndk-bundle-r19c/android-toolchain
ANDROID_API_VERSION=24

# build OpenBLAS first
TOOLCHAIN_R19_GFORTRAN_ENABLED=/root/android-toolchain-standalone-r19-gfortran/aarch64-linux-android-4.9

_SYSROOT="/root/ndk-bundle-r19c/platforms/android-24/arch-arm64"
_C_FLAGS="--sysroot=$_SYSROOT -I$TOOLCHAIN_ROOT/sysroot/usr/include -I$TOOLCHAIN_ROOT/sysroot/usr/include/aarch64-linux-android -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"
_CPP_FLAGS="--sysroot=$_SYSROOT -I$TOOLCHAIN_ROOT/sysroot/usr/include -I$TOOLCHAIN_ROOT/sysroot/usr/include/aarch64-linux-android -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"
_LDFLAGS="--sysroot=$_SYSROOT -L$TOOLCHAIN_R19_GFORTRAN_ENABLED/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib -L$TOOLCHAIN_ROOT/sysroot/usr/lib/aarch64-linux-android/24"

wget https://github.com/xianyi/OpenBLAS/archive/v0.3.6.tar.gz
tar -xf v0.3.6.tar.gz && mv OpenBLAS-0.3.6 OpenBLAS
rm v0.3.6.tar.gz

cd OpenBLAS
# make clean
PATH=$TOOLCHAIN_R19_GFORTRAN_ENABLED/bin/:$PATH LDFLAGS=$_LDFLAGS CFLAGS=$_C_FLAGS CPPFLAGS=$_CPP_FLAGS make TARGET=ARMV8 BINARY=64 HOSTCC=gcc AR=aarch64-linux-android-ar CC=aarch64-linux-android-gcc FC=aarch64-linux-android-gfortran -j${nproc}
mkdir -p build
make PREFIX=`pwd`/build install
cd ..