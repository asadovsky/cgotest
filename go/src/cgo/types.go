package main

import (
	"unsafe"

	"v.io/v23/verror"
)

/*
#include <stdlib.h>
#include "types.h"
*/
import "C"

////////////////////////////////////////
// C.XString

func (x *C.XString) free() {
	C.free(unsafe.Pointer(x.p))
}

func (x *C.XString) init(s string) {
	x.p = C.CString(s)
	x.n = C.int(len(s))
}

////////////////////////////////////////
// C.XBytes

func (x *C.XBytes) free() {
	C.free(x.p)
}

func (x *C.XBytes) init(b []byte) {
	x.p = unsafe.Pointer(C.CString(string(b)))
	x.n = C.int(len(b))
}

////////////////////////////////////////
// C.XVError

func newXVError() *C.XVError {
	return (*C.XVError)(C.malloc(C.sizeof_XVError))
}

func (x *C.XVError) init(e error) {
	x.id.init(string(verror.ErrorID(e)))
	x.actionCode = C.uint(verror.Action(e))
	x.msg.init(e.Error())
	x.stack.init(verror.Stack(e).String())
}

////////////////////////////////////////
// C.XFoo

func (x *C.XFoo) free() {
	x.str.free()
	x.arr.free()
}

func (x *C.XFoo) init(str string, arr []byte, num int32) {
	x.str.init(str)
	x.arr.init(arr)
	x.num = C.int(num)
}
