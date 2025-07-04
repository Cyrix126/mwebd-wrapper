#!/bin/bash

CGO_ENABLED=1 
# Linux
go build -o libmwebd.so -buildmode=c-shared .

# Mac OS
go build -o libmwebd.dylib -buildmode=c-shared .

# Windows (requires gcc)
GOOS=windows
GOARCH=arm64
CC=<insert gcc of choice>
go build -o libmwebd.dll -buildmode=c-shared .

# Android

## Download ndk
mkdir android-ndk
wget https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip
unzip android-ndk-r21b-linux-x86_64.zip
rm android-ndk-r21b-linux-x86_64.zip
mv android-ndk-r21b android-ndk

GOOS=android

## ARM v7
GOARCH=arm 
GOARM=7 
CC=android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang \
go build -o libmwebd_android_armv7.so -buildmode=c-shared .

## ARM64
GOARCH=arm64
CC=android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
go build -o libmwebd_android_arm64.so -buildmode=c-shared .

