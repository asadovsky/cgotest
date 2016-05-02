#include "lib.h"

int CSimpleFunc(int x) {
  return 2 * x;
}

void CCallbackFunc(int x, XIntCallback cb) {
  cb.f(cb.h, 2 * x);
}

// From c/golib.h, which we can't include.
int XAdd(int, int);

int CAdd(int a, int b) {
  return XAdd(a, b);
}
