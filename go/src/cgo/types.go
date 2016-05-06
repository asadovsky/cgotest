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
	x.n = C.int(len(b))
	x.p = (*C.uint8_t)(C.malloc(C.size_t(len(b))))
	C.memcpy(unsafe.Pointer(x.p), unsafe.Pointer(&b[0]), C.size_t(len(b)))
}

func (x *C.x_Bytes) toBytes() []byte {
	defer C.free(unsafe.Pointer(x.p))
	return C.GoBytes(unsafe.Pointer(x.p), x.n)
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
