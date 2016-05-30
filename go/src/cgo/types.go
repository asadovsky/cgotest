package main

import (
	"unsafe"

	"v.io/v23/verror"
)

// All "x.toFoo" methods free the memory associated with x.

/*
#include <stdlib.h>
#include <string.h>
#include "lib.h"
*/
import "C"

////////////////////////////////////////
// C.x_String

func (x *C.x_String) init(s string) {
	x.n = C.int(len(s))
	x.p = C.CString(s)
}

func (x *C.x_String) toString() string {
	if x.p == nil {
		return ""
	}
	defer C.free(unsafe.Pointer(x.p))
	return C.GoStringN(x.p, x.n)
}

////////////////////////////////////////
// C.x_Bytes

func init() {
	if C.sizeof_uint8_t != 1 {
		panic(C.sizeof_uint8_t)
	}
}

func (x *C.x_Bytes) init(b []byte) {
	// Special-case for len(b) == 0, because malloc(0) can return an invalid
	// pointer, and memcpy fails on invalid pointers even if size is 0.
	if len(b) == 0 {
		x.n = 0
		x.p = nil
		return
	}
	x.n = C.int(len(b))
	x.p = (*C.uint8_t)(C.malloc(C.size_t(x.n)))
	C.memcpy(unsafe.Pointer(x.p), unsafe.Pointer(&b[0]), C.size_t(x.n))
}

func (x *C.x_Bytes) toBytes() []byte {
	if x.p == nil {
		return nil
	}
	defer C.free(unsafe.Pointer(x.p))
	return C.GoBytes(unsafe.Pointer(x.p), x.n)
}

////////////////////////////////////////
// C.x_Strings

func (x *C.x_Strings) at(i int) *C.x_String {
	return (*C.x_String)(unsafe.Pointer(uintptr(unsafe.Pointer(x.p)) + uintptr(C.size_t(i)*C.sizeof_x_String)))
}

func (x *C.x_Strings) init(strs []string) {
	x.n = C.int(len(strs))
	x.p = (*C.x_String)(C.malloc(C.size_t(x.n) * C.sizeof_x_String))
	for i, v := range strs {
		x.at(i).init(v)
	}
}

func (x *C.x_Strings) toStrings() []string {
	if x.p == nil {
		return nil
	}
	defer C.free(unsafe.Pointer(x.p))
	res := make([]string, x.n)
	for i := 0; i < int(x.n); i++ {
		res[i] = x.at(i).toString()
	}
	return res
}

////////////////////////////////////////
// C.x_VError

func (x *C.x_VError) init(err error) {
	if err == nil {
		return
	}
	x.id.init(string(verror.ErrorID(err)))
	x.actionCode = C.uint(verror.Action(err))
	x.msg.init(err.Error())
	x.stack.init(verror.Stack(err).String())
}

////////////////////////////////////////
// C.x_Foo

func (x *C.x_Foo) init(str string, arr []byte, num int32) {
	x.str.init(str)
	x.arr.init(arr)
	x.num = C.int(num)
}
