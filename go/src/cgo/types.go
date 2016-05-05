package main

import (
	"unsafe"

	"v.io/v23/verror"
)

/*
#include <stdlib.h>
#include "lib.h"
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

// Frees the memory associated with this object.
func (x *C.XString) toString() string {
	defer x.free()
	return C.GoStringN(x.p, x.n)
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

// Frees the memory associated with this object.
func (x *C.XBytes) toBytes() []byte {
	defer x.free()
	return C.GoBytes(x.p, x.n)
}

////////////////////////////////////////
// C.XVError

func (x *C.XVError) init(e error) {
	if e == nil {
		return
	}
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
