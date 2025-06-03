#!/bin/bash
# 
## Ios (from MacOS only)
CGO_ENABLED=1
CC=clang
GOOS=ios
GOARCH=arm64
go build -o libmwed.a -buildmode=c-archive .

