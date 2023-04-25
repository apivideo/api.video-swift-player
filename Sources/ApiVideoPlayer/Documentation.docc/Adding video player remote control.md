# Adding video player remote control

On this article we will dive on how to display a remote controller on your lockscreen and notification center

## Table of contents

- [Receive events from remote-control](#receive-events-from-remote-control)
    - [UIKit](#uikit)
    - [SwiftUI](#swiftui)
- [Documentation](#documentation)
- [Dependencies](#dependencies)

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

After you have instanciated the player, call the method 'allowRemoteControl' to send data to the remote control

```
override func viewDidLoad() {
...
self.playerView.allowRemoteControl()
...
```

Now you need to override the 'remoteControlReceived' function and pass the events to 'remoteControlEventReceived' of ApiVideoSwiftPlayer

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

## Remove remote control
You can use the 'removeRemoteControl' function to take out the remote control.

For instance, when a video reaches its end, you have the option to remove it.
It's important to note that using this method will pause the video, and if you play it again, the remote control will be displayed one more.
```
public func didEnd() {
...
    self.playerView.removeRemoteControl()
...

}
```

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
