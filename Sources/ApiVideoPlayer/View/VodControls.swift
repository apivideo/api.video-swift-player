//
//  File.swift
//  
//
//  Created by Romain Petit on 30/03/2022.
//

import Foundation
import UIKit
import AVFoundation

@available(iOS 13.0, *)
class VodControls: UIView{
    
    private var timer: Timer?
    private var isPlaying = false
    private var avPlayer: AVPlayer!
    private var pView: UIView!
    
    
    init(frame: CGRect, parentView: UIView, player: AVPlayer) {
        self.avPlayer = player
        self.pView = parentView
        super.init(frame: frame)
        setVodControls()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let vodControlGoForward15Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        btn.tintColor = .systemOrange
        return btn
    }()
    let vodControlGoBackward15Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        btn.tintColor = .systemOrange
        return btn
    }()
    
    let vodControlSliderView: UIView = {
        let view = UIView()
        return view
    }()
    
    let vodControlSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    let vodControlTimerLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private func setVodControls(){
        //Controls View
        pView.addSubview(self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        //Play Pause Button
        self.addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(seekPlayAction), for: .touchUpInside)
        getIconPlayBtn()
        
        //Go Forward Button
        self.addSubview(vodControlGoForward15Button)
        vodControlGoForward15Button.addTarget(self, action: #selector(goForward15Action), for: .touchUpInside)
        
        //Go Backward Button
        self.addSubview(vodControlGoBackward15Button)
        vodControlGoBackward15Button.addTarget(self, action: #selector(goBackward15Action), for: .touchUpInside)
        
        //Slider View
        self.addSubview(vodControlSliderView)
        vodControlSliderView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)
        
        //Slider
        vodControlSliderView.addSubview(vodControlSlider)
        vodControlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        vodControlSlider.thumbTintColor = UIColor.orange
        
        //Timer Label
        vodControlSliderView.addSubview(vodControlTimerLabel)
        vodControlTimerLabel.textColor = UIColor.orange
        
        
        // TODO: handle device orientation to set the style of controls
        
        // TODO: handle the disparition of controls
        
        
        setVodControlConstraints()
        activateTimer()
    }
    
    
    private func setVodControlConstraints(){
        //Controls View
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: pView.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: pView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: pView.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: pView.bottomAnchor).isActive = true
        
        
        //Play Pause Button
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.centerXAnchor.constraint(equalTo: pView.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        //Go Forward Button
        vodControlGoForward15Button.translatesAutoresizingMaskIntoConstraints = false
        vodControlGoForward15Button.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
        vodControlGoForward15Button.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor, constant: (self.frame.width / 16)).isActive = true
        vodControlGoForward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        vodControlGoForward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        print("frame : \(self.frame.width / 16)")
        
        //Go Backward Button
        vodControlGoBackward15Button.translatesAutoresizingMaskIntoConstraints = false
        vodControlGoBackward15Button.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
        vodControlGoBackward15Button.rightAnchor.constraint(equalTo: playPauseButton.leftAnchor, constant: -(self.frame.width / 16)).isActive = true
        vodControlGoBackward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        vodControlGoBackward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //        vodControlGoForward15Button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        //Slider View
        vodControlSliderView.translatesAutoresizingMaskIntoConstraints = false
        vodControlSliderView.centerXAnchor.constraint(equalTo: pView.centerXAnchor).isActive = true
        vodControlSliderView.rightAnchor.constraint(equalTo: pView.rightAnchor).isActive = true
        vodControlSliderView.leftAnchor.constraint(equalTo: pView.leftAnchor).isActive = true
        vodControlSliderView.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: -12).isActive = true
        vodControlSliderView.heightAnchor.constraint(equalToConstant: (pView.frame.height / 4)).isActive = true
        
        //Slider
        vodControlSlider.translatesAutoresizingMaskIntoConstraints = false
        vodControlSlider.centerYAnchor.constraint(equalTo: vodControlSliderView.centerYAnchor).isActive = true
        vodControlSlider.leftAnchor.constraint(equalTo: vodControlSliderView.leftAnchor, constant: 5).isActive = true
        vodControlSlider.rightAnchor.constraint(equalTo: vodControlTimerLabel.leftAnchor, constant: -10).isActive = true
        
        //Timer Label
        vodControlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        vodControlTimerLabel.centerYAnchor.constraint(equalTo: vodControlSliderView.centerYAnchor).isActive = true
        vodControlTimerLabel.rightAnchor.constraint(equalTo: vodControlSliderView.rightAnchor, constant: -10).isActive = true
        
        
    }
    
    
    func seekControls(){
        if(!playPauseButton.isHidden){
            UIView.animate(withDuration: 0.2, animations: {
                self.playPauseButton.alpha = 0
            }) { (finished) in
                self.playPauseButton.isHidden = finished
            }
        }else{
            self.playPauseButton.alpha = 0
            self.playPauseButton.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.playPauseButton.alpha = 1
            }
            activateTimer()
        }
        
        if(!vodControlGoForward15Button.isHidden){
            UIView.animate(withDuration: 0.2, animations: {
                self.vodControlGoForward15Button.alpha = 0
            }) { (finished) in
                self.vodControlGoForward15Button.isHidden = finished
            }
        }else{
            self.vodControlGoForward15Button.alpha = 0
            self.vodControlGoForward15Button.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.vodControlGoForward15Button.alpha = 1
            }
            activateTimer()
        }
        
        if(!vodControlGoBackward15Button.isHidden){
            UIView.animate(withDuration: 0.2, animations: {
                self.vodControlGoBackward15Button.alpha = 0
            }) { (finished) in
                self.vodControlGoBackward15Button.isHidden = finished
            }
        }else{
            self.vodControlGoBackward15Button.alpha = 0
            self.vodControlGoBackward15Button.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.vodControlGoBackward15Button.alpha = 1
            }
            activateTimer()
        }
        
        if(!vodControlSliderView.isHidden){
            UIView.animate(withDuration: 0.2, animations: {
                self.vodControlSliderView.alpha = 0
            }) { (finished) in
                self.vodControlSliderView.isHidden = finished
            }
        }else{
            self.vodControlSliderView.alpha = 0
            self.vodControlSliderView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.vodControlSliderView.alpha = 1
            }
            activateTimer()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("view tapped")
        resetTimer()
        seekControls()
    }
    
    @objc func seekPlayAction() {
        print("seek play")
        resetTimer()
        if !isPlaying{
            avPlayer.play()
            isPlaying = true
        }else{
            avPlayer.pause()
            isPlaying = false
        }
        getIconPlayBtn()
        activateTimer()
    }
    
    @objc func goForward15Action() {
        print("goForward15Action")
        resetTimer()
        guard let currentTime = avPlayer?.currentTime() else { return }
        let currentTimeInSecondsMinus15 =  CMTimeGetSeconds(currentTime).advanced(by: 15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus15), timescale: 1)
        avPlayer?.seek(to: seekTime)
        activateTimer()
    }
    
    @objc func goBackward15Action() {
        print("goBackward15Action")
        resetTimer()
        guard let currentTime = avPlayer?.currentTime() else { return }
        let currentTimeInSecondsMinus15 =  CMTimeGetSeconds(currentTime).advanced(by: -15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus15), timescale: 1)
        avPlayer?.seek(to: seekTime)
        activateTimer()
    }
    
    public func updatePlayerState() {
        guard let currentTime = avPlayer?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        vodControlSlider.value = Float(currentTimeInSeconds)
        if let currentItem = avPlayer?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            vodControlSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
            // Update time remaining label
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds
            
            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            vodControlTimerLabel.text = "\(minsStr):\(secsStr)"
        }
    }
    
    private func activateTimer(){
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(disableControls), userInfo: nil, repeats: false)
    }
    
    private func resetTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    @objc func disableControls() {
        seekControls()
    }
    
    private func getIconPlayBtn(){
        if !isPlaying{
            if #available(tvOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            playPauseButton.tintColor = .systemOrange
        }else{
            if #available(tvOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            playPauseButton.tintColor = .systemOrange
        }
    }
    
}
