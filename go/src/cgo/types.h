#include <stdint.h>

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
