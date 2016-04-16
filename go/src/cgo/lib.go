package main

import (
	"errors"
)

/*
#include <math.h>
#include "types.h"
*/
import "C"

//export Add
func Add(a, b int32) int32 {
	return a + b
}

//export AddAndSub
func AddAndSub(a, b int32) (int32, int32) {
	return a + b, a - b
}

//export AddAndSubPtrs
func AddAndSubPtrs(a, b int32, add, sub *C.int) {
	*add = C.int(a + b)
	*sub = C.int(a - b)
}

var errDivByZero = errors.New("cannot divide by zero")

//export Div
func Div(a, b int32) (int32, *C.Err) {
	if b == 0 {
		e := newErr()
		e.init(errDivByZero)
		return 0, e
	}
	return a / b, nil
}

//export DivPtrs
func DivPtrs(a, b int32, res *C.int, e *C.Err) {
	if b == 0 {
		e.init(errDivByZero)
		return
	}
	*res = C.int(a / b)
}

//export Sqrt
func Sqrt(x float64) float64 {
	res, err := C.sqrt(C.double(x))
	if err != nil {
		panic(err)
	}
	return float64(res)
}

//export Echo
func Echo(x C.Str, res *C.Str) {
	defer x.free()
	res.init(C.GoStringN(x.p, x.n))
}

//export EchoFoo
func EchoFoo(x C.Foo, res *C.Foo, e *C.Err) {
	defer x.free()
	if x.num == 0 {
		e.init(errors.New("num must be non-zero"))
		return
	}
	res.init(C.GoStringN(x.str.p, x.str.n), C.GoBytes(x.arr.p, x.arr.n), int32((x.num)))
}
