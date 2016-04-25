import Foundation

func addAndSub(a: Int32, b: Int32) -> (Int32, Int32) {
  var x: Int32 = 0, y: Int32 = 0
  AddAndSubPtrs(a, b, &x, &y)
  return (x, y)
}

func div(a: Int32, b: Int32) throws -> Int32 {
  var res: Int32 = 0
  try VError.maybeThrow {
    DivPtrs(a, b, &res, $0)
  }
  return res
}

func echo(x: String) -> String {
  var res = Str()
  Echo(Str(s: x)!, &res)
  return res.toString()!
}

func echoFoo(x: SwiftFoo) throws -> SwiftFoo {
  var res = Foo()
  try VError.maybeThrow {
    EchoFoo(Foo(f: x)!, &res, $0)
  }
  return SwiftFoo(f: res)
}
