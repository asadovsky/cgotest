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
// C.Str

func (c *C.Str) free() {
	C.free(unsafe.Pointer(c.p))
}

func (c *C.Str) init(s string) {
	c.p = C.CString(s)
	c.n = C.int(len(s))
}

////////////////////////////////////////
// C.Arr

func (c *C.Arr) free() {
	C.free(c.p)
}

func (c *C.Arr) init(b []byte) {
	c.p = unsafe.Pointer(C.CString(string(b)))
	c.n = C.int(len(b))
}

////////////////////////////////////////
// C.Err

func newErr() *C.Err {
	return (*C.Err)(C.malloc(C.sizeof_Err))
}

func (c *C.Err) init(e error) {
	c.id.init(string(verror.ErrorID(e)))
	c.actionCode = C.uint(verror.Action(e))
	c.msg.init(e.Error())
	c.stack.init(verror.Stack(e).String())
}

////////////////////////////////////////
// C.Foo

func (c *C.Foo) free() {
	c.str.free()
	c.arr.free()
}

func (c *C.Foo) init(str string, arr []byte, num int32) {
	c.str.init(str)
	c.arr.init(arr)
	c.num = C.int(num)
}
