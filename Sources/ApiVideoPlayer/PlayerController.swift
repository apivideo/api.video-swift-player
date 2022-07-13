import Foundation
import AVFoundation
import AVKit
import ApiVideoPlayerAnalytics

@available(iOS 14.0, *)
public class PlayerController: NSObject{
    public var events: PlayerEvents? = nil
    private let avPlayer = AVPlayer(playerItem: nil)
    private var analytics: PlayerAnalytics?
    private var option : Options?
    private let videoType: VideoType = .vod
    private let videoId: String!
    private var playerManifest : PlayerManifest!
    private var basicPlayerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var subtitles : [Subtitle] = [Subtitle(language: "Off", code: nil, isSelected: false)]
    private var isFirstPlay = true
    private let isReady: (() -> ())?
    public var viewController: UIViewController?
    
    init(videoId: String, events: PlayerEvents? = nil, isReady: (() -> ())? = nil) throws {
        self.events = events
        self.videoId = videoId
        self.isReady = isReady
        super.init()
        getPlayerJSON(videoType: .vod){ (error) in
            if error == nil {
                self.isReady!()
            }
        }
    }
    
    private func getVideoUrl(videoType: VideoType, privateToken: String? = nil) -> String{
        var baseUrl = ""
        if videoType == .vod {
            baseUrl = "https://cdn.api.video/vod/"
        }else{
            baseUrl = "https://live.api.video/"
        }
        var url: String!
        if privateToken != nil{
            url = baseUrl + "\(self.videoId!)/token/\(privateToken!)/player.json"
        }else{
            url = baseUrl + "\(self.videoId!)/player.json"
        }
        
        return url
    }
    
    
    private func getPlayerJSON(videoType: VideoType, completion: @escaping (Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data,response, error) in
            if data != nil {
                do{
                    self.playerManifest = try JSONDecoder().decode(PlayerManifest.self, from: data!)
                }catch let decodeError{
                    completion(decodeError)
                    return
                }
                
                self.setUpAnalytics(url:self.playerManifest.video.src)
                self.setUpPlayerUrl()
                completion(nil)
            } else {
                completion(error)
            }
        }
        
    }
    
    public func setView(_ view: UIView,_ playerLayer: AVPlayerLayer){
        playerLayer.player = avPlayer
        view.layer.addSublayer(playerLayer)
    }
    
    private func setUpPlayerUrl(){
        if let url = URL(string: (self.playerManifest.video.src)){
            setUpPlayer(url)
        }else{
            print("Error with video url, trying with mp4")
            retrySetUpPlayerUrlWithMp4()
        }
        
        
    }
    
    private func retrySetUpPlayerUrlWithMp4(){
        basicPlayerItem = nil
        guard let mp4 = self.playerManifest.video.mp4 else {
            print("Error there is no mp4")
            return
        }
        if let url = URL(string: (mp4)){
            setUpPlayer(url)
        }else{
            print("error url trying mp4")
            return
        }
    }
    
    private func setUpPlayer(_ url : URL){
        let item = AVPlayerItem(url: url)
        if(avPlayer.currentItem != nil){
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        }
        avPlayer.replaceCurrentItem(with: item)
        avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    public func setTimerObserver(callback: @escaping (() -> ())){
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            callback()
        })
    }
    
    public func removeTimeObserver(){
        if let timeObserver = timeObserver{
            avPlayer.removeTimeObserver(timeObserver)
        }
    }
    
    private func setUpAnalytics(url: String){
        do {
            option = try Options(
                mediaUrl: url, metadata: [],
                onSessionIdReceived: { (id) in
                    print("session ID : \(id)")
                })
        } catch {
            print("error with the url")
        }
        
        analytics = PlayerAnalytics(options: option!)
    }
    public func isPlaying()-> Bool{
        return avPlayer.isPlaying()
    }
    
    public func play(){
        avPlayer.play()
    }
    
    public func replay(){
        analytics?.seek(from: Float(CMTimeGetSeconds(avPlayer.currentTime())), to: Float(CMTimeGetSeconds(CMTime.zero))){ (result) in
            switch result {
            case .success(_):break
            case .failure(let error):
                print("analytics error on seek event: \(error)")
            }
        }
        avPlayer.seek(to: CMTime.zero)
        avPlayer.play()
        analytics?.resume(){(result) in
            switch result {
            case .success(_):break
            case .failure(let error):
                print("analytics error on resume event: \(error)")
            }
        }
        
        if(self.events?.didRePlay != nil){
            self.events?.didRePlay!()
        }
    }
    
    public func pause(){
        avPlayer.pause()
    }
    
    public func seek(time: Double){
        let currentTimeInSeconds =  CMTimeGetSeconds(avPlayer.currentTime()).advanced(by: time)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSeconds), timescale: 1)
        seek(seekTime: seekTime, currentTimeInSeconds: currentTimeInSeconds)
    }
    
    public func seek(to: Double){
        let seekTime = CMTime(seconds: to, preferredTimescale: 1)
        seek(seekTime: seekTime, currentTimeInSeconds: CMTimeGetSeconds(seekTime))
    }
    
    private func seek(seekTime: CMTime, currentTimeInSeconds: Float64){
        var cts = currentTimeInSeconds
        avPlayer.seek(to: seekTime)
        analytics?.seek(from: Float(CMTimeGetSeconds(avPlayer.currentTime())), to: Float(CMTimeGetSeconds(seekTime))){(result) in
            switch result {
            case .success(let data):
                print("player analytics seek : \(data)")
            case .failure(let error):
                print("player analytics seek : \(error)")
            }
        }
        if(self.events?.didSeekTime != nil){
            if cts < 0 {
                cts = 0.0
            }
            self.events?.didSeekTime!(currentTime.seconds, cts)
        }
    }
    
    public var isMuted: Bool {
        get {
            return avPlayer.isMuted
        }
        set(newValue) {
            avPlayer.isMuted = newValue
            if newValue{
                if(self.events?.didMute != nil){
                    self.events?.didMute!()
                }
            }else{
                if(self.events?.didUnMute != nil){
                    self.events?.didUnMute!()
                }
            }
        }
    }
    
    public var isLoop: Bool = false
    
    public var volume: Float{
        get{ return avPlayer.volume}
        set(newVolume){
            avPlayer.volume = newVolume
            if(self.events?.didSetVolume != nil){
                self.events?.didSetVolume!(volume)
            }
        }
    }
    
    public var duration: CMTime{
        get{
            return avPlayer.currentItem!.asset.duration
        }
    }
    
    public var currentTime: CMTime{
        return avPlayer.currentTime()
    }
    
    public func goFullScreen(){
        let playerViewController = AVPlayerViewController()
        playerViewController.player = avPlayer
        viewController?.present(playerViewController, animated: true) {
            self.avPlayer.play()
        }
    }
    
    func selectSubtitle(_ language: String? = nil){
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            if(language == nil){
                hideSubtitle()
            }else{
                let locale = Locale(identifier: language!)
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    avPlayer.currentItem!.select(option, in: group)
                }
            }
        }
    }
    
    func hideSubtitle(){
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            avPlayer.currentItem!.select(nil, in: group)
        }
    }
    
    func getSubtitlesFromVideo() -> [Subtitle]{
        let current = getCurrentLocaleSubtitle()
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            for option in group.options {
                if(option.displayName != "CC"){
                    var sub = Subtitle(language: option.displayName, code: option.extendedLanguageTag)
                    if(current?.languageCode == sub.code){
                        sub.isSelected = true
                    }
                    subtitles.append(sub)
                }
            }
        }
        return subtitles
    }
    
    private func getCurrentLocaleSubtitle() -> Locale?{
        var locale: Locale?
        if let playerItem = avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
            let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            locale = selectedOption?.locale
        }
        if(locale == nil){
            subtitles[0].isSelected = true
        }
        return locale
    }
    
    public func showSubtitle(language: String){
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            let locale = Locale(identifier: language)
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                avPlayer.currentItem!.select(option, in: group)
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status"{
            if avPlayer.currentItem?.status ==  .failed{
                guard let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url else{
                    return
                }
                if(url.absoluteString.contains(".mp4")){
                    print("Error with video mp4")
                    return
                }else{
                    print("Error with video url, trying with mp4")
                    retrySetUpPlayerUrlWithMp4()
                }
            }
        }
        if keyPath == "rate" {
            let status = self.avPlayer.timeControlStatus
            switch status{
            case .paused:
                //Paused mode
                self.analytics?.pause(){(result) in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        print("analytics error on pause event: \(error)")
                    }
                }
                if(self.events?.didPause != nil){
                    self.events?.didPause!()
                }
            case .waitingToPlayAtSpecifiedRate:
                //Resumed
                if(isFirstPlay){
                    isFirstPlay = false
                    self.analytics?.play(){(result) in
                        switch result {
                        case .success(_): break
                        case .failure(let error):
                            print("analytics error on play event: \(error)")
                        }
                    }
                }else{
                    self.analytics?.resume(){(result) in
                        switch result {
                        case .success(_): break
                        case .failure(let error):
                            print("analytics error on resume event: \(error)")
                        }
                    }
                }
                if(self.events?.didPlay != nil){
                    self.events?.didPlay!()
                }
            case .playing:
                //Video Ended
                if isLoop {
                    replay()
                    if(self.events?.didLoop != nil){
                        self.events?.didLoop!()
                    }
                }
                self.analytics?.end(){(result)in
                    switch result {
                    case .success(_):break
                    case .failure(let error):
                        print("analytics error on ended event: \(error)")
                    }
                }
                if(self.events?.didEnd != nil){
                    self.events?.didEnd!()
                }
            @unknown default:
                break
            }
        }
        
    }

    deinit {
        avPlayer.removeObserver(self, forKeyPath: "rate", context: nil)
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
    }
}

extension AVPlayer{
    @available(iOS 10.0, *)
    func isPlaying()-> Bool{
        return (self.rate != 0 && self.error == nil)
    }
}
