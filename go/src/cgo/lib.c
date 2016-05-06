#include "lib.h"

int c_SimpleFunc(int x) {
  return 2 * x;
}

void c_CallbackFunc(int x, x_IntCallback cb) {
  cb.f(cb.h, 2 * x);
}

// From c/golib.h, which we can't include.
int x_Add(int, int);

int c_Add(int a, int b) {
  return x_Add(a, b);
}
