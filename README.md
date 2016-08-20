# cgotest

Prototype of Swift-to-Go bridge, using Cgo.

Subsequent work, including Java-to-Go bridge:
- https://github.com/vanadium/go.ref/tree/master/services/syncbase/bridge/cgo
- https://github.com/vanadium/java/tree/master/syncbase/src/main/java/io/v/syncbase/core
- https://github.com/vanadium/swift/tree/master/SyncbaseCore

## Building and running

First, install the v23:base profile for amd64-ios and arm64-ios:

    jiri profile install -target=amd64-ios v23:base
    jiri profile install -target=arm64-ios v23:base

Next, build the Cgo shared libraries:

    make build-ios

Finally, open the CgoSwift project in Xcode and run the tests.

## Design

Async, non-streaming:
- Swift function F accepts callback B
- F uses GCD to dispatch the Cgo function on a non-main queue
- When the Cgo function returns, we dispatch B on the main queue

Async, streaming:
- Swift function F accepts callback B
- F uses GCD to dispatch the Cgo function on a non-main queue, passing it a
  C-style callback that curries a handle to B
- When the C-style callback gets invoked, we retrieve B (via the handle) and
  dispatch it on the main queue

In both cases, we can also make the callback queue configurable instead of
always using the main queue.

## References

- https://golang.org/cmd/cgo/
- https://github.com/golang/go/wiki/cgo
- https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html
- http://oleb.net/blog/2015/06/c-callbacks-in-swift/
