import Foundation

var globalRefMap = RefMap()

// Thread-safe map of handles to object references.
class RefMap {
  // TODO: Use some sort of mixin for locking, if possible.
  private let q = dispatch_queue_create("RefMap", DISPATCH_QUEUE_SERIAL)
  private var nextId: UInt64 = 0
  private var m: [UInt64: Any] = [:]

  func put(x: Any) -> UInt64 {
    var h: UInt64 = 0
    dispatch_sync(q) {
      self.m[self.nextId] = x
      h = self.nextId
      self.nextId += 1
    }
    return h
  }

  func get(h: UInt64) -> Any? {
    var x: Any? = nil
    dispatch_sync(q) {
      x = self.m[h]
    }
    return x
  }

  func release(h: UInt64) -> Any? {
    var x: Any? = nil
    dispatch_sync(q) {
      x = self.m.removeValueForKey(h)
    }
    return x
  }
}
