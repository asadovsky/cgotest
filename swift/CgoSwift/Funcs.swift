import Foundation

func addAndSub(a: Int32, b: Int32) -> (Int32, Int32) {
  var x: Int32 = 0, y: Int32 = 0
  XAddAndSubPtrs(a, b, &x, &y)
  return (x, y)
}

func div(a: Int32, b: Int32) throws -> Int32 {
  var res: Int32 = 0
  try VError.maybeThrow {
    XDivPtrs(a, b, &res, $0)
  }
  return res
}

func echo(s: String) -> String {
  var res = XString()
  XEcho(XString(s: s)!, &res)
  return res.toString()!
}

func echoFoo(f: Foo) throws -> Foo {
  var res = XFoo()
  try VError.maybeThrow {
    XEchoFoo(XFoo(f: f)!, &res, $0)
  }
  return res.toFoo()!
}

func streamInts(x: Int32, onInt: OnInt) {
  let hOnInt = globalRefMap.put(onInt)
  XStreamInts(x, XIntCallback(h: hOnInt, f: { h, x in (globalRefMap.get(h) as! OnInt)(x) }))
  globalRefMap.release(hOnInt)
}

// Note, this implementation is problematic in that the onInt and onDone callbacks are invoked on
// some Cgo thread, not the original thread.
func asyncStreamIntsProblematic(x: Int32, onInt: OnInt, onDone: OnDone) {
  XAsyncStreamInts(x, XStreamCallbacks(
    hOnInt: globalRefMap.put(onInt),
    hOnDone: globalRefMap.put(onDone),
    onInt: { h, x in (globalRefMap.get(h) as! OnInt)(x) },
    onDone: { hOnInt, hOnDone in globalRefMap.release(hOnInt); (globalRefMap.release(hOnDone) as! OnDone)() }))
}

// TODO: Make result queue user-configurable.
func asyncStreamInts(x: Int32, onInt: OnInt, onDone: OnDone) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    XAsyncStreamInts(x, XStreamCallbacks(
      hOnInt: globalRefMap.put(onInt),
      hOnDone: globalRefMap.put(onDone),
      onInt: { h, x in dispatch_async(dispatch_get_main_queue()) { (globalRefMap.get(h) as! OnInt)(x) }},
      onDone: { hOnInt, hOnDone in dispatch_async(dispatch_get_main_queue()) { globalRefMap.release(hOnInt); (globalRefMap.release(hOnDone) as! OnDone)() }}))
  }
}
