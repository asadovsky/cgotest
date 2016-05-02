# cgotest

Cgo experiments.

Async, non-streaming:
- Swift function F accepts callback B
- F uses GCD to dispatch the Cgo function on a non-main queue
- When the Cgo function returns, F dispatches B on the main queue

Async, streaming:
- Swift function F accepts callback B
- F puts B in RefMap, receives handle H
- F uses GCD to dispatch the Cgo function on a non-main queue, passing it a
  C-style callback that curries H
- When the C-style callback gets invoked, Swift retrieves B (via H), then
  dispatches on the main queue

In both cases, we can also make the callback queue configurable instead of
always using the main queue.

References:
https://golang.org/cmd/cgo/
https://github.com/golang/go/wiki/cgo
https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html
http://oleb.net/blog/2015/06/c-callbacks-in-swift/
