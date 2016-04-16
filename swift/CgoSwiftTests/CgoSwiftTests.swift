import XCTest
@testable import CgoSwift

class CgoSwiftTests: XCTestCase {
  func testSimple() {
    print(AddAndSub(2, 1))
  }

  func testExample() {
    print("Hello, world!")
    print(Str())
  }

  func testEchoFoo() {
    let arr = "arr".dataUsingEncoding(NSUTF8StringEncoding)!
    let foo = SwiftFoo(str: "str", arr: arr, num: 42)
    print(foo)
    print(SwiftFoo(f: Foo(f: foo)!))
  }
}
