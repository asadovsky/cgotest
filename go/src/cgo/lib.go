package main

import (
	"errors"
	"fmt"
	"time"
)

/*
#include <math.h>
#include "lib.h"

static void CallOnData(OnData onData, int x) {
  onData(x);
}
static void CallOnDone(OnDone onDone) {
  onDone();
}
*/
import "C"

//export XAdd
func XAdd(a, b int32) int32 {
	return a + b
}

//export XAddAndSub
func XAddAndSub(a, b int32) (int32, int32) {
	return a + b, a - b
}

//export XAddAndSubPtrs
func XAddAndSubPtrs(a, b int32, add, sub *C.int) {
	*add = C.int(a + b)
	*sub = C.int(a - b)
}

var errDivByZero = errors.New("cannot divide by zero")

//export XDiv
func XDiv(a, b int32) (int32, *C.XVError) {
	if b == 0 {
		e := newXVError()
		e.init(errDivByZero)
		return 0, e
	}
	return a / b, nil
}

//export XDivPtrs
func XDivPtrs(a, b int32, res *C.int, e *C.XVError) {
	if b == 0 {
		e.init(errDivByZero)
		return
	}
	*res = C.int(a / b)
}

//export XSqrt
func XSqrt(x float64) float64 {
	res, err := C.sqrt(C.double(x))
	if err != nil {
		panic(err)
	}
	return float64(res)
}

//export XEcho
func XEcho(x C.XString, res *C.XString) {
	// TODO: We may wish to move the freeing of inputs to a Swift-specific C or
	// Cgo API, because for Java/JNI (unlike Swift) we may be able to avoid
	// copying data passed from Java to C.
	defer x.free()
	res.init(C.GoStringN(x.p, x.n))
}

//export XEchoFoo
func XEchoFoo(x C.XFoo, res *C.XFoo, e *C.XVError) {
	// See TODO above.
	defer x.free()
	if x.num == 0 {
		e.init(errors.New("num must be non-zero"))
		return
	}
	res.init(C.GoStringN(x.str.p, x.str.n), C.GoBytes(x.arr.p, x.arr.n), int32((x.num)))
}

//export XStreamingFunc
func XStreamingFunc(x int32, onData C.OnData) {
	for i := 0; i < 5; i++ {
		fmt.Println(time.Now())
		C.CallOnData(onData, C.int(int32(i)*x))
	}
	fmt.Println(time.Now())
}

//export XAsyncStreamingFunc
func XAsyncStreamingFunc(x int32, onData C.OnData, onDone C.OnDone) {
	go func() {
		XStreamingFunc(x, onData)
		C.CallOnDone(onDone)
	}()
}

//export XAsyncAdd
func XAsyncAdd(a, b int32, onData C.OnData) {
	go func() {
		C.CallOnData(onData, C.int(XAdd(a, b)))
	}()
}
