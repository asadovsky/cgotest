#include <stdint.h>

// String.
typedef struct {
  const char* p;
  int n;
} Str;

// Byte array.
typedef struct {
  const void* p;
  int n;
} Arr;

// VError.
typedef struct {
  Str id;
  unsigned int actionCode;
  Str msg;
  Str stack;
} Err;

// Custom struct, containing a string, a byte array, and an int.
typedef struct {
  Str str;
  Arr arr;
  int num;
} Foo;
