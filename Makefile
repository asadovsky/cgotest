SHELL := /bin/bash -euo pipefail
GOPATH := $(shell pwd)/go:$(JIRI_ROOT)/release/go

.DELETE_ON_ERROR:

all: c-main-archive

.PHONY: build-shared
build-shared: $(shell find go/src/cgo)
	go build -buildmode=c-shared -o c/golib.so cgo

.PHONY: build-archive
build-archive: $(shell find go/src/cgo)
	go env GOPATH
	go build -buildmode=c-archive -o c/golib.a cgo
	jiri go -target=amd64-ios build -buildmode=c-archive -tags=ios -o c/golib_amd64_ios.a cgo
	jiri go -target=arm64-ios build -buildmode=c-archive -tags=ios -o c/golib_arm64_ios.a cgo
	cp go/src/cgo/lib.h c/

# To run the .so version of c-main:
#   LD_LIBRARY_PATH=./c DYLD_LIBRARY_PATH=./c ./c/main
.PHONY: c-main-shared
c-main-shared: c/main.c build-shared
	gcc -Wall -o c/main $< c/golib.so

.PHONY: c-main-archive
c-main-archive: c/main.c build-archive
	gcc -Wall -o c/main $< c/golib.a

.PHONY: clean
clean:
	rm -rf c/golib* c/main c/lib.h
