#!/bin/bash

# Linux
go build -o libmwebd.so -buildmode=c-shared .

# Mac OS
go build -o libmwebd.dylib -buildmode=c-shared .

# Windows
go build -o libmwebd.dll -buildmode=c-shared .
