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
