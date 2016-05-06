package main

import (
	"errors"
)

/*
#include <math.h>
#include "lib.h"

static void CallIntCallback(x_IntCallback cb, int x) {
  cb.f(cb.h, x);
}
static void CallStreamCallbacksOnDone(x_StreamCallbacks cbs) {
  cbs.onDone(cbs.hOnInt, cbs.hOnDone);
}
*/
import "C"

//export x_Add
func x_Add(a, b int32) int32 {
	return a + b
}

//export x_AddAndSub
func x_AddAndSub(a, b int32) (int32, int32) {
	return a + b, a - b
}

//export x_AddAndSubPtrs
func x_AddAndSubPtrs(a, b int32, add, sub *C.int) {
	*add = C.int(a + b)
	*sub = C.int(a - b)
}

var errDivByZero = errors.New("cannot divide by zero")

//export x_Div
func x_Div(a, b int32) (int32, C.x_VError) {
	if b == 0 {
		e := C.x_VError{}
		e.init(errDivByZero)
		return 0, e
	}
	return a / b, C.x_VError{}
}

//export x_DivPtrs
func x_DivPtrs(a, b int32, res *C.int, e *C.x_VError) {
	if b == 0 {
		e.init(errDivByZero)
		return
	}
	*res = C.int(a / b)
}

//export x_Sqrt
func x_Sqrt(x float64) float64 {
	res, err := C.sqrt(C.double(x))
	if err != nil {
		panic(err)
	}
	return float64(res)
}

//export x_Echo
func x_Echo(x C.x_String, res *C.x_String) {
	// TODO: We may wish to move the freeing of inputs to a Swift-specific C or
	// Cgo API, because for Java/JNI (unlike Swift) we may be able to avoid
	// copying data passed from Java to C.
	res.init(x.toString())
}

//export x_EchoFoo
func x_EchoFoo(x C.x_Foo, res *C.x_Foo, e *C.x_VError) {
	// See TODO above.
	xStr := x.str.toString()
	xArr := x.arr.toBytes()
	if x.num == 0 {
		e.init(errors.New("num must be non-zero"))
		return
	}
	res.init(xStr, xArr, int32((x.num)))
}

//export x_StreamInts
func x_StreamInts(x int32, cb C.x_IntCallback) {
	for i := 0; i < int(x); i++ {
		C.CallIntCallback(cb, C.int(i))
	}
}

//export x_AsyncStreamInts
func x_AsyncStreamInts(x int32, cbs C.x_StreamCallbacks) {
	go func() {
		x_StreamInts(x, C.x_IntCallback{h: cbs.hOnInt, f: cbs.onInt})
		C.CallStreamCallbacksOnDone(cbs)
	}()
}

//export x_AsyncAdd
func x_AsyncAdd(a, b int32, cb C.x_IntCallback) {
	go func() {
		C.CallIntCallback(cb, C.int(x_Add(a, b)))
	}()
}
