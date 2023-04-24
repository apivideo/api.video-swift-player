# Adding video player remote control

On this article we will dive on how to display a remote controller on your lockscreen and notification center

## Table of contents

- [Adding permission](#adding-permission)
    - [Swift Package Manager](#swift-package-manager)
    - [Cocoapods](#cocoapods)
- [Receive events from remote-control](#receive-events-from-remote-control)
    - [UIKit](#uikit)
    - [SwiftUI](#swiftui)
- [Documentation](#documentation)
- [Dependencies](#dependencies)

## Adding permission
First of all you have to add audio in background permission. 
To do so follow the instruction : 
    1. Go to your target application
    2. Select "Signing & Capabilities"
    3. Then click on " + Capability" button 
    4. On this pop up select "Background Modes"
    5. finally select "Audio, AirPlay and Picture in Picture"

## Receive events from remote-control
### UIKit
On your AppDelegate.swift, 
    - add in 'didFinishLaunchingWithOptions' function: 
```
// Start receiving events
UIApplication.shared.beginReceivingRemoteControlEvents()
```
    - add in 'didDiscardSceneSessions' function:
```
// Stop receiving events
UIApplication.shared.endReceivingRemoteControlEvents()
```
Then in your ViewController.swift

override the 'remoteControlReceived' function and pass the events to 'remoteControlEventReceived' of ApiVideoSwiftPlayer

```
override func remoteControlReceived(with event: UIEvent?) {
    if let event = event {
        if event.type == .remoteControl {
            self.playerView.remoteControlEventReceived(with: event)
        }
    }
}
```

### SwiftUI
For SwiftUI you don't have any to do, it's already handle by the library.

That's it, now you can test it and play with the remote control.


## Documentation

* [API documentation](https://apivideo.github.io/api.video-swift-player/documentation/apivideoplayer/)
* [api.video documentation](https://docs.api.video)

## Dependencies

We are using external library

| Plugin                                                                                | README                                                                         |
|---------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| [ApiVideoPlayerAnalytics](https://github.com/apivideo/api.video-ios-player-analytics) | [README.md](https://github.com/apivideo/api.video-ios-player-analytics#readme) |

## FAQ

If you have any questions, ask us here: [https://community.api.video](https://community.api.video) or
use [Issues](https://github.com/apivideo/api.video-ios-player-analytics/issues).
