[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)
&nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-swift-player?style=social)](https://github.com/apivideo/api.video-swift-player)
&nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)
<h1 align="center">api.video Swift player</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast
video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in
your app.

# Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
    - [Installation](#installation)
        - [Swift Package Manager](#swift-package-manager)
        - [Cocoapods](#cocoapods)
    - [Retrieve your video Id](#retrieve-your-video-id)
- [Sample application](#sample-application)
- [Documentation](#documentation)
- [Dependencies](#dependencies)

# Project description

Easily integrate a video player for videos from [api.video](https://api.video) in your iOS
application.

# Getting started

## Installation

### Swift Package Manager

In the Project Navigator select your own project. Then select the project in the Project section and click on the Package Dependencies tab. Click on the "+" button at the bottom. Paste the below url on the search bar on the top right. Finaly click on "Add package" button.

```
 https://github.com/apivideo/api.video-swift-player
```
Or add this in your Package.swift
```
  dependencies: [
        .package(url: "https://github.com/apivideo/api.video-swift-player.git", from: "1.0.5"),
    ],
```

### Cocoapods
Add `pod 'ApiVideoPlayer', '1.0.5'` in your `Podfile`

Run `pod install`


## Retrieve your video Id

At this point, you must have uploaded a least one video to your account. If you haven't
see [how to upload a video](https://docs.api.video/docs/upload-a-video-regular-upload). You'll need
a video Id to use this component and play a video from api.video. To get yours, follow these steps:

1. [Log into your account](https://dashboard.api.video/login) or create
   one [here](https://dashboard.api.video/register).
2. Copy your API key (sandbox or production if you are subscribed to one of
   our [plan](https://api.video/pricing)).
3. Go to [the official api.video documentation](https://docs.api.video/docs).
4. Log into your account in the top right corner. If it's already done, be sure it's the account you
   want to use.
5. Go to API Reference -> Videos -> [List all videos](https://docs.api.video/reference/list-videos)
6. On the right, be sure the "Authentication" section contains the API key you want to use.
7. Generate your upload token by clicking the "Try It!" button in the right section
8. Copy the "videoId" value of one of elements of the response in the right section.

Alternatively, you can find your video Id in the video details of
your [dashboard](https://dashboard.api.video).

## Code sample

1. Import the library 

```
import ApiVideoPlayer
```
2. Instantiate the Player view:

```swift
    let playerView: ApiVideoPlayerView = {
        let videoOptions = VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: .vod)
        return ApiVideoPlayerView(frame: .zero, videoOptions: videoOptions)
    }()
```
3. Add heritance to PlayerDelegate
you must implement all the methods to avoid error
```swift
extension YourViewController: PlayerDelegate {
    public func didPrepare() {
        // Do what you whant when didPrepare is called
    }

    public func didReady() {
        // Do what you whant when didReady is called
    }

    public func didPause() {
        // Do what you whant when didPause is called
    }

    public func didPlay() {
        // Do what you whant when didPlay is called
    }

    public func didReplay() {
        // Do what you whant when didReplay is called
    }

    public func didMute() {
        // Do what you whant when didMute is called
    }

    public func didUnMute() {
        // Do what you whant when didUnMute is called
    }

    public func didLoop() {
        // Do what you whant when didLoop is called
    }

    public func didSetVolume(_: Float) {
        // Do what you whant when didSetVolume is called
    }

    public func didSeek(_: CMTime, _: CMTime) {
        // Do what you whant when didSeek is called
    }

    public func didEnd() {
        // Do what you whant when didEnd is called
    }

    public func didError(_: Error) {
        // Do what you whant when didError is called
    }

    public func didVideoSizeChanged(_: CGSize) {
        // Do what you whant when didVideoSizeChanged is called
    }
}
```

4. Implement playerView and delegate in your view controller

```swift
    override func viewDidLoad() {
        ...
        self.addSubview(playerView)
        self.playerView.addDelegate(self)
        ...
    }
```
5. To use full screen and subtitle
```swift
    override func viewDidAppear(_ animated: Bool) {
        ...
        playerView.viewController = self
        ...
    }
```

# Sample application

A demo application demonstrates how to use player.
See [`/example`](https://github.com/apivideo/api.video-swift-player/tree/main/Examples)
folder.

On the first run, you will have to set your video Id:
1. Replace "YOUR_VIDEO_ID" by your video Id

# Documentation

* [API documentation](https://apivideo.github.io/api.video-swift-player/documentation/apivideoplayer/)
* [api.video documentation](https://docs.api.video)

# Dependencies

We are using external library

| Plugin | README |
| ------ | ------ |
| [ApiVideoPlayerAnalytics](https://github.com/apivideo/api.video-ios-player-analytics) | [README.md](https://github.com/apivideo/api.video-ios-player-analytics#readme) |

# FAQ

If you have any questions, ask us here: [https://community.api.video](https://community.api.video).
Or use [Issues](https://github.com/apivideo/api.video-ios-player-analytics/issues).
