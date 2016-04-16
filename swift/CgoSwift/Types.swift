// Note: Imported C structs have a default initializer in Swift that initializes all of the struct's
// fields to zero.
// https://developer.apple.com/library/ios/releasenotes/DeveloperTools/RN-Xcode/Chapters/xc6_release_notes.html

// TODO:
// - Change C struct names to XString, XBytes, XVError, XCustom
// - Change XFoo extension to implement both init(Foo) and toFoo()

import Foundation

extension Str {
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
    self.p = UnsafePointer<Int8>(p)
    self.n = Int32(n)
  }

  // Returns a String that takes ownership of the memory associated with this object.
  func toString() -> String? {
    if p == nil {
      return nil
    }
    return String(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), encoding: NSUTF8StringEncoding, freeWhenDone: true)
  }
}

extension Arr {
  // TODO: Use [UInt8] instead of NSData?
  init?(data: NSData) {
    let p = malloc(data.length)
    if p == nil {
      return nil
    }
    let n = data.length
    data.getBytes(p, length: n)
    self.p = UnsafePointer<Void>(p)
    self.n = Int32(n)
  }

  // Returns an NSData that takes ownership of the memory associated with this object.
  func toNSData() -> NSData? {
    if p == nil {
      return nil
    }
    return NSData(bytesNoCopy: UnsafeMutablePointer<Void>(p), length: Int(n), freeWhenDone: true)
  }
}

extension Foo {
  init?(f: SwiftFoo) {
    guard let str = Str(s: f.str) else {
      return nil
    }
    guard let arr = Arr(data: f.arr) else {
      return nil
    }
    self.init(str: str, arr: arr, num: f.num)
  }
}

public struct SwiftFoo: CustomStringConvertible {
  public let str: String
  public let arr: NSData
  public let num: Int32

  init(str: String, arr: NSData, num: Int32) {
    self.str = str
    self.arr = arr
    self.num = num
  }

  init(f: Foo) {
    self.init(str: f.str.toString()!, arr: f.arr.toNSData()!, num: f.num)
  }

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

  // Takes ownership of the memory associated with e.
  init?(e: Err) {
    if e.id.p == nil {
      return nil
    }
    // TODO: Stop requiring id, msg, and stack to be valid UTF8?
    id = e.id.toString()!
    actionCode = e.actionCode
    msg = e.msg.toString()!
    stack = e.stack.toString()!
  }

  static func maybeThrow<T>(@noescape f: UnsafeMutablePointer<Err> -> T) throws -> T {
    var e = Err()
    let res = f(&e)
    if let err = VError(e: e) {
      throw err
    }
    return res
  }
}
