# Changelog
All changes to this project will be documented in this file.

## [1.1.4] - 2023-10-09
- Fix analytics when currentTime < 0
- Examples: Add default videoId

## [1.1.3] - 2023-06-15
- Make player available for iOS 11 and above
- PlayerError send custom message to LocalizedError

## [1.1.2] - 2023-06-05
- Make method addDelegate(s) and removeDelegate(s) public

## [1.1.1] - 2023-05-10
- Add speedrate selector
- Add remote control on lockscreen

## [1.1.0] - 2023-03-15
- Add private vod videos
- Add live feature
- Change callback to delegate for UIKit 

## [1.0.5] - 2022-11-23
- Add didReady event
- Use completionhandler in seek method to get the result of the seek, before doing any other action.

## [1.0.4] - 2022-11-03
- Add an API to automatically play the video after loading. See `ApiVideoPlayerController`'s `autoplay` field.

## [1.0.3] - 2022-10-27
- Add an API to change the video id on the fly. Check out for `videoOptions`.
- Add an API to get the video size in the controller
- Publicize API on subtitles in the controller

## [1.0.2] - 2022-10-25
- Publicize `ApiVideoPlayerController`
- Add output API in `ApiVideoPlayerController` to set/remove `AVPlayerItemOutput`

## [1.0.1] - 2022-10-20
- Add SwiftUI player
- Fix subtitle bug 
- Change ios target version to ios 13

## [1.0.0] - 2022-08-04
- First version
