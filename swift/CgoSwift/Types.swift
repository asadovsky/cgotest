// Note: In Swift, default initializers for imported C structs zero-initialize all fields.
// https://developer.apple.com/library/ios/releasenotes/DeveloperTools/RN-Xcode/Chapters/xc6_release_notes.html

import Foundation

typealias OnInt = Int32 -> ()
typealias OnDone = () -> ()

func mallocOrDie<T>(n: Int) -> UnsafeMutablePointer<T> {
  let p = malloc(n)
  if p == nil {
    fatalError()
  }
  return unsafeBitCast(p, UnsafeMutablePointer<T>.self)
}

// All "x.extract" methods free the memory associated with x.

extension x_String {
  init?(_ s: String) {
    // TODO: If possible, make one copy instead of two, e.g. using s.getCString.
    guard let data = s.dataUsingEncoding(NSUTF8StringEncoding) else {
      return nil
    }
    p = mallocOrDie(data.length)
    n = Int32(data.length)
    data.getBytes(p, length: data.length)
  }

  func extract() -> String? {
    if p == nil {
      return nil
    }
    return String(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), encoding: NSUTF8StringEncoding, freeWhenDone: true)
  }
}

extension x_Bytes {
  // TODO: Use [UInt8] instead of NSData?
  init?(_ data: NSData) {
    p = mallocOrDie(data.length)
    n = Int32(data.length)
    data.getBytes(p, length: data.length)
  }

  func extract() -> NSData? {
    if p == nil {
      return nil
    }
    return NSData(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), freeWhenDone: true)
  }
}

// Note, we don't define init?(VError) since we never pass Swift VError objects to Go.
extension x_VError {
  func extract() -> VError? {
    if id.p == nil {
      return nil
    }
    // Take ownership of all memory before checking optionals.
    let vId = id.extract(), vMsg = msg.extract(), vStack = stack.extract()
    // TODO: Stop requiring id, msg, and stack to be valid UTF8?
    return VError(id: vId!, actionCode: actionCode, msg: vMsg!, stack: vStack!)
  }
}

extension x_Foo {
  init?(_ f: Foo) {
    guard let str = x_String(f.str) else {
      return nil
    }
    guard let arr = x_Bytes(f.arr) else {
      return nil
    }
    self.init(str: str, arr: arr, num: f.num)
  }

  func extract() -> Foo? {
    // Take ownership of all memory before checking optionals.
    let vStr = str.extract(), vArr = arr.extract()
    if vStr == nil || vArr == nil {
      return nil
    }
    return Foo(str: vStr!, arr: vArr!, num: num)
  }
}

public struct Foo: CustomStringConvertible {
  public let str: String
  public let arr: NSData
  public let num: Int32

  public var description: String {
    let arrDesc = String(data: arr, encoding: NSUTF8StringEncoding)!
    return [str, arrDesc, num.description].joinWithSeparator(",")
  }
}

public struct VError: ErrorType {
  public let id: String
  public let actionCode: UInt32
  public let msg: String
  public let stack: String

  static func maybeThrow<T>(@noescape f: UnsafeMutablePointer<x_VError> -> T) throws -> T {
    var e = x_VError()
    let res = f(&e)
    if let err = e.extract() {
      throw err
    }
    return res
  }
}
