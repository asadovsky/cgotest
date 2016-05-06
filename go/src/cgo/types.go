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
// C.XString

func (x *C.XString) init(s string) {
	x.n = C.int(len(s))
	x.p = C.CString(s)
}

func (x *C.XString) toString() string {
	defer C.free(unsafe.Pointer(x.p))
	return C.GoStringN(x.p, x.n)
}

////////////////////////////////////////
// C.XBytes

func init() {
	if C.sizeof_uint8_t != 1 {
		panic(C.sizeof_uint8_t)
	}
}

func (x *C.XBytes) init(b []byte) {
	x.n = C.int(len(b))
	x.p = (*C.uint8_t)(C.malloc(C.size_t(len(b))))
	C.memcpy(x.p, unsafe.Pointer(&b[0]), C.size_t(len(b)))
}

func (x *C.XBytes) toBytes() []byte {
	defer C.free(x.p)
	return C.GoBytes(x.p, x.n)
}

////////////////////////////////////////
// C.XVError

func (x *C.XVError) init(err error) {
	if err == nil {
		return
	}
	x.id.init(string(verror.ErrorID(err)))
	x.actionCode = C.uint(verror.Action(err))
	x.msg.init(err.Error())
	x.stack.init(verror.Stack(err).String())
}

////////////////////////////////////////
// C.XFoo

func (x *C.XFoo) init(str string, arr []byte, num int32) {
	x.str.init(str)
	x.arr.init(arr)
	x.num = C.int(num)
}
