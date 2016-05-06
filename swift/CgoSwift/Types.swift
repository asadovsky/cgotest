// Note: Imported C structs have a default initializer in Swift that zero-initializes all fields.
// https://developer.apple.com/library/ios/releasenotes/DeveloperTools/RN-Xcode/Chapters/xc6_release_notes.html

import Foundation

typealias OnInt = Int32 -> ()
typealias OnDone = () -> ()

extension x_String {
  init?(s: String) {
    // TODO: If possible, make one copy instead of two, e.g. using s.getCString.
    guard let data = s.dataUsingEncoding(NSUTF8StringEncoding) else {
      return nil
    }
    let p = malloc(data.length)
    if p == nil {
      return nil
    }
    let n = data.length
    data.getBytes(p, length: n)
    self.p = UnsafeMutablePointer<Int8>(p)
    self.n = Int32(n)
  }

  // Return value takes ownership of the memory associated with this object.
  func toString() -> String? {
    if p == nil {
      return nil
    }
    return String(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), encoding: NSUTF8StringEncoding, freeWhenDone: true)
  }
}

extension x_Bytes {
  // TODO: Use [UInt8] instead of NSData?
  init?(data: NSData) {
    let p = malloc(data.length)
    if p == nil {
      return nil
    }
    let n = data.length
    data.getBytes(p, length: n)
    self.p = UnsafeMutablePointer<UInt8>(p)
    self.n = Int32(n)
  }

  // Return value takes ownership of the memory associated with this object.
  func toNSData() -> NSData? {
    if p == nil {
      return nil
    }
    return NSData(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), freeWhenDone: true)
  }
}

// Note, we don't define init?(VError) since we never pass Swift VError objects to Go.
extension x_VError {
  // Return value takes ownership of the memory associated with this object.
  func toVError() -> VError? {
    if id.p == nil {
      return nil
    }
    // Take ownership of all memory before checking optionals.
    let vId = id.toString(), vMsg = msg.toString(), vStack = stack.toString()
    // TODO: Stop requiring id, msg, and stack to be valid UTF8?
    return VError(id: vId!, actionCode: actionCode, msg: vMsg!, stack: vStack!)
  }
}

extension x_Foo {
  init?(f: Foo) {
    guard let str = x_String(s: f.str) else {
      return nil
    }
    guard let arr = x_Bytes(data: f.arr) else {
      return nil
    }
    self.init(str: str, arr: arr, num: f.num)
  }

  func toFoo() -> Foo? {
    // Take ownership of all memory before checking optionals.
    let vStr = str.toString(), vArr = arr.toNSData()
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
    if let err = e.toVError() {
      throw err
    }
    return res
  }
}
