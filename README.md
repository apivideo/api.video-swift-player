<!--<documentation_excluded>-->
[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)
&nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-swift-player?style=social)](https://github.com/apivideo/api.video-swift-player)
&nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)

<h1 align="center">api.video Swift player</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast
video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in
your app.

## Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Cocoapods](#cocoapods)
  - [Retrieve your video Id](#retrieve-your-video-id)
  - [Usage](#usage)
    - [Remote control](#remote-control)
    - [Supported player views](#supported-player-views)
  - [Play an api.video video in your AVPlayer](#play-an-apivideo-video-in-your-avplayer)
- [Sample application](#sample-application)
- [Documentation](#documentation)
- [Dependencies](#dependencies)
- [FAQ](#faq)

<!--</documentation_excluded>-->
<!--<documentation_only>
---
title: api.video Swift Player
meta: 
  description: The official api.video Swift Player component for api.video. [api.video](https://api.video/) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.
---

# api.video Swift Player

[api.video](https://api.video/) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.

</documentation_only>-->
## Project description

Easily integrate a video player for videos from [api.video](https://api.video) in your Swift
application.

![](https://github.com/apivideo/api.video-swift-player/blob/main/Assets/player-preview.png)

## Getting started

### Installation

#### Swift Package Manager

In the Project Navigator select your own project. Then select the project in the Project section and click on the
Package Dependencies tab. Click on the "+" button at the bottom. Paste the below url on the search bar on the top right.
Finaly click on "Add package" button.

```
 https://github.com/apivideo/api.video-swift-player
```

Or add this in your Package.swift

```
  dependencies: [
        .package(url: "https://github.com/apivideo/api.video-swift-player.git", from: "1.2.0"),
    ],
```

#### Cocoapods

Add `pod 'ApiVideoPlayer', '1.2.0'` in your `Podfile`

Run `pod install`

### Retrieve your video Id

At this point, you must have uploaded a least one video to your account. If you haven't
see [how to upload a video](https://docs.api.video/vod/upload-a-video-regular-upload/). You'll need
a video Id to use this component and play a video from api.video. To get yours, follow these steps:

1. [Log into your account](https://dashboard.api.video/login) or create
   one [here](https://dashboard.api.video/register).
2. Copy your API key (sandbox or production if you are subscribed to one of
   our [plan](https://api.video/pricing)).
3. Go to [the official api.video documentation](https://docs.api.video/).
4. Go to API Reference -> Videos -> [List all videos](https://docs.api.video/reference/api/Videos#list-all-video-objects)
5. Create a `get` request to the `/videos` endpoint based on the reference, using a tool like Postman.
6. Copy the "videoId" value of one of elements of the API response.

Alternatively, you can find your video Id in the video details of
your [dashboard](https://dashboard.api.video).

### Usage

1. Imports the library

```
import ApiVideoPlayer
```

2. Instantiates the player view

```swift
let playerView: ApiVideoPlayerView = ApiVideoPlayerView(frame: .zero, videoOptions: VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: .vod)) // for private video VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: .vod, token: "YOUR_PRIVATE_VIDEO_TOKEN")
```

3. Adds the player view as a subview of your view controller

```swift
override func viewDidLoad() {
    ...
    self.addSubview(playerView)
}
```

4. Delegates the player events

To be able to use the player delegate, you must implement the PlayerDelegate protocol.

```swift
extension YourViewController: PlayerDelegate {
    public func didPrepare() {
        // Do what you want when didPrepare is called
    }

    public func didReady() {
        // Do what you want when didReady is called
    }

    public func didPause() {
        // Do what you want when didPause is called
    }

    public func didPlay() {
        // Do what you want when didPlay is called
    }

    public func didReplay() {
        // Do what you want when didReplay is called
    }

    public func didMute() {
        // Do what you want when didMute is called
    }

    public func didUnMute() {
        // Do what you want when didUnMute is called
    }

    public func didLoop() {
        // Do what you want when didLoop is called
    }

    public func didSetVolume(_: Float) {
        // Do what you want when didSetVolume is called
    }

    public func didSeek(_: CMTime, _: CMTime) {
        // Do what you want when didSeek is called
    }

    public func didEnd() {
        // Do what you want when didEnd is called
    }

    public func didError(_: Error) {
        // Do what you want when didError is called
    }

    public func didVideoSizeChanged(_: CGSize) {
        // Do what you want when didVideoSizeChanged is called
    }
}
```

5. Registers the delegate

```swift
override func viewDidLoad() {
    ...
    self.playerView.addDelegate(self)
}
```

6. To use fullscreen, you must pass the view controller to the player view

```swift
override func viewDidAppear(_ animated: Bool) {
    ...
    playerView.viewController = self
}
```

#### Remote control

If you want to enable the remote control do the following:

```swift
override func viewDidLoad() {
    ...
    self.playerView.enableRemoteControl = true
}
```

When you have to remove it set `enableRemoteControl` to false

By default the remote control is hidden.

#### Supported player views

The api.video Swift player comes with a specific view `ApiVideoPlayerView` to display the video
and its controller. If you require a customization of this view such as changing a button color,...,
you can contact [us](https://github.com/apivideo/api.video-swift-player/issues).

Otherwise, in the `ApiVideoPlayerController`, you can also use the following views:

- [`AVPlayerViewController`](https://developer.apple.com/documentation/avkit/avplayerviewcontroller): AVKit view

```swift
// Create the api.video controller
let controller = ApiVideoPlayerController(
    videoOptions: VideoOptions(videoId: "vi77Dgk0F8eLwaFOtC5870yn", videoType: .vod),
    delegates: [],
    autoplay: false
)
// Create the AVKit AVPlayerViewController
let viewController = AVPlayerViewController()

/// Pass the api.video controller to the AVKit AVPlayerViewController
viewController.setApiVideoPlayerController(controller)
// Prepare the view
self.addChild(viewController)
view.addSubview(viewController.view)
// Set the AVKit AVPlayerViewController frame size according to your needs (here it's the whole screen)
viewController.view.frame = self.view.frame
// Do what you want with the video controller (play, pause, seek,...)
controller.play()
```

- [`AVPlayerLayer`](https://developer.apple.com/documentation/avfoundation/avplayerlayer). A view that only display the video. It requires more work to be used.

### Play an api.video video in your AVPlayer

If you are using AVPlayer directly, you can use the api.video Swift extensions:

1. Create a video

```swift
let videoOptions = VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: .vod))
// for private video VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: .vod, token: "YOUR_PRIVATE_VIDEO_TOKEN")
```

2. Pass it to your AVPlayer

```swift
val player = AVPlayer() // You already have that in your code
avPlayer.replaceCurrentItem(withHls: videoOptions)
```

## Sample application

A demo application demonstrates how to use player.
See [`/example`](https://github.com/apivideo/api.video-swift-player/tree/main/Examples)
folder.

## Documentation

- [Player documentation](https://apivideo.github.io/api.video-swift-player/documentation/apivideoplayer/)
- [api.video documentation](https://docs.api.video)

## Dependencies

We are using external library

| Plugin                                                                                  | README                                                                           |
| --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [ApiVideoPlayerAnalytics](https://github.com/apivideo/api.video-swift-player-analytics) | [README.md](https://github.com/apivideo/api.video-swift-player-analytics#readme) |

## FAQ

If you have any questions, ask us here: [https://community.api.video](https://community.api.video) or
use [Issues](https://github.com/apivideo/api.video-swift-player/issues).
