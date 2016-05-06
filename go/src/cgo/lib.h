#ifndef CGO_LIB_H_
#define CGO_LIB_H_

#include <stdint.h>

////////////////////////////////////////
// Structs

// string
typedef struct {
  char* p;
  int n;
} XString;

// []byte
typedef struct {
  uint8_t* p;
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

// Callbacks are represented as struct {XHandle, f(XHandle, ...)} to allow for
// currying RefMap handles to Swift closures.
// https://forums.developer.apple.com/message/15725#15725

typedef int XHandle;

typedef struct {
  XHandle h;
  void (*f)(XHandle, int);
} XIntCallback;

typedef struct {
  XHandle hOnInt;
  XHandle hOnDone;
  void (*onInt)(XHandle hOnInt, int);
  void (*onDone)(XHandle hOnInt, XHandle hOnDone);
} XStreamCallbacks;

int CSimpleFunc(int);
void CCallbackFunc(int, XIntCallback);

// CAdd calls Cgo's XAdd, i.e. it's an example of how to export a pure C
// function that wraps a Cgo function.
int CAdd(int, int);

#endif  // CGO_LIB_H_
