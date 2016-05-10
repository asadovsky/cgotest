#ifndef CGO_LIB_H_
#define CGO_LIB_H_

#include <stdint.h>

////////////////////////////////////////
// Structs

// string
typedef struct {
  char* p;
  int n;
} x_String;

// []byte
typedef struct {
  uint8_t* p;
  int n;
} x_Bytes;

// verror.E
typedef struct {
  x_String id;
  unsigned int actionCode;
  x_String msg;
  x_String stack;
} x_VError;

// type Foo struct {
//   str string
//   arr []byte
//   num int
// }
typedef struct {
  x_String str;
  x_Bytes arr;
  int num;
} x_Foo;

////////////////////////////////////////
// Functions

// Callbacks are represented as struct {x_Handle, f(x_Handle, ...)} to allow for
// currying RefMap handles to Swift closures.
// https://forums.developer.apple.com/message/15725#15725

typedef long x_Handle;

typedef struct {
  x_Handle h;
  void (*f)(x_Handle, int);
} x_IntCallback;

typedef struct {
  x_Handle hOnInt;
  x_Handle hOnDone;
  void (*onInt)(x_Handle hOnInt, int);
  void (*onDone)(x_Handle hOnInt, x_Handle hOnDone);
} x_StreamCallbacks;

int c_SimpleFunc(int);
void c_CallbackFunc(int, x_IntCallback);

// c_Add calls Cgo's x_Add, i.e. it's an example of how to export a pure C
// function that wraps a Cgo function.
int c_Add(int, int);

#endif  // CGO_LIB_H_
