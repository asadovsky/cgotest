#ifndef CGO_LIB_H_
#define CGO_LIB_H_

#include <stdint.h>

////////////////////////////////////////
// Structs

// string
typedef struct {
  const char* p;
  int n;
} XString;

// []byte
typedef struct {
  const void* p;
  int n;
} XBytes;

// verror.E
typedef struct {
  XString id;
  unsigned int actionCode;
  XString msg;
  XString stack;
} XVError;

// type Foo struct {
//   str string
//   arr []byte
//   num int
// }
typedef struct {
  XString str;
  XBytes arr;
  int num;
} XFoo;

////////////////////////////////////////
// Functions

typedef void (*OnData)(int);
typedef void (*OnDone)(void);

int CSimpleFunc(int);
void CStreamingFunc(int, OnData);

// CAdd calls Cgo's XAdd, i.e. it's an example of how to export a pure C
// function that wraps a Cgo function.
int CAdd(int, int);

#endif  // CGO_LIB_H_
