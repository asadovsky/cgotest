import Foundation

func addAndSub(a: Int32, _ b: Int32) -> (Int32, Int32) {
  var x: Int32 = 0, y: Int32 = 0
  x_AddAndSubPtrs(a, b, &x, &y)
  return (x, y)
}

func divide(a: Int32, _ b: Int32) throws -> Int32 {
  var res: Int32 = 0
  try VError.maybeThrow {
    x_DivPtrs(a, b, &res, $0)
  }
  return res
}

func echo(s: String) -> String {
  var res = x_String()
  x_Echo(x_String(s)!, &res)
  return res.extract()!
}

func echoFoo(f: Foo) throws -> Foo {
  var res = x_Foo()
  try VError.maybeThrow {
    x_EchoFoo(x_Foo(f)!, &res, $0)
  }
  return res.extract()!
}

class Box<T> {
  let v: T

  init(_ v: T) {
    self.v = v
  }
}

class Pair<T1, T2> {
  let v1: T1, v2: T2

  init(_ v1: T1, _ v2: T2) {
    self.v1 = v1
    self.v2 = v2
  }
}

func toOpaque<T: AnyObject>(obj: T, retained: Bool) -> UInt {
  let u = retained ? Unmanaged.passRetained(obj) : Unmanaged.passUnretained(obj)
  return unsafeBitCast(UnsafeMutablePointer<Void>(u.toOpaque()), UInt.self);
}

func fromOpaque<T: AnyObject>(ptr: UInt, retained: Bool) -> T {
  let u = Unmanaged<T>.fromOpaque(COpaquePointer(bitPattern: ptr))
  return retained ? u.takeRetainedValue() : u.takeUnretainedValue();
}

func streamInts(x: Int32, onInt: OnInt) {
  let ptr = toOpaque(Box(onInt), retained: true)
  x_StreamInts(x, x_IntCallback(
    h: ptr,
    f: { h, x in (fromOpaque(h, retained: false) as Box<OnInt>).v(x) }))
  fromOpaque(ptr, retained: true) as Box<OnInt>
}

// Note, this implementation is problematic in that the onInt and onDone callbacks are invoked on
// some Cgo thread, not the original thread.
func asyncStreamIntsProblematic(x: Int32, onInt: OnInt, onDone: OnDone) {
  x_AsyncStreamInts(x, x_StreamCallbacks(
    h: toOpaque(Pair(onInt, onDone), retained: true),
    onInt: { h, x in (fromOpaque(h, retained: false) as Pair<OnInt, OnDone>).v1(x) },
    onDone: { h in (fromOpaque(h, retained: true) as Pair<OnInt, OnDone>).v2() }))
}

// TODO: Make result queue user-configurable.
func asyncStreamInts(x: Int32, onInt: OnInt, onDone: OnDone) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    x_AsyncStreamInts(x, x_StreamCallbacks(
      h: toOpaque(Pair(onInt, onDone), retained: true),
      onInt: { h, x in dispatch_async(dispatch_get_main_queue()) { (fromOpaque(h, retained: false) as Pair<OnInt, OnDone>).v1(x) }},
      onDone: { h in dispatch_async(dispatch_get_main_queue()) { (fromOpaque(h, retained: true) as Pair<OnInt, OnDone>).v2() }}))
  }
}
