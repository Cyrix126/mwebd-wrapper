#!/bin/bash
 
## Ios (from MacOS only)
mkdir -p ios_lib
CGO_ENABLED=1
CC=clang
GOOS=ios
GOARCH=arm64
go build -o ios_lib/libmwebd.a -buildmode=c-archive .

