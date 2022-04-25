import Foundation
import UIKit
import AVFoundation

@available(iOS 13.0, *)
class LiveControls: UIView{
    private var timer: Timer?
    private var isPlaying = false
    private var avPlayer: AVPlayer!
    private var pView: UIView!
    
    
    init(frame: CGRect, parentView: UIView, player: AVPlayer) {
        self.avPlayer = player
        self.pView = parentView
        super.init(frame: frame)
        setLiveControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let liveControlSliderView: UIView = {
        let view = UIView()
        return view
    }()
    
    let liveControlSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    let liveControlGoLive: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "livephoto"), for: .normal)
        btn.tintColor = .lightGray
        return btn
    }()
    
    
    
    private func setLiveControls(){
        //Controls View
        pView.addSubview(self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        //Play Pause Button
        self.addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(seekPlayAction), for: .touchUpInside)
        getIconPlayBtn()
        
        
        //Slider View
        self.addSubview(liveControlSliderView)
        liveControlSliderView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)
        
        //Slider
        liveControlSliderView.addSubview(liveControlSlider)
        liveControlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        liveControlSlider.thumbTintColor = UIColor.orange
        
        //Go to direct Button
        
        liveControlSliderView.addSubview(liveControlGoLive)
        liveControlGoLive.addTarget(self, action: #selector(goToDirectAction), for: .touchUpInside)
        
        
        setLiveControlConstraints()
        activateTimer()
    }
    
    private func setLiveControlConstraints(){
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
        
        //Slider View
        liveControlSliderView.translatesAutoresizingMaskIntoConstraints = false
        liveControlSliderView.centerXAnchor.constraint(equalTo: pView.centerXAnchor).isActive = true
        liveControlSliderView.rightAnchor.constraint(equalTo: pView.rightAnchor).isActive = true
        liveControlSliderView.leftAnchor.constraint(equalTo: pView.leftAnchor).isActive = true
        liveControlSliderView.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: -12).isActive = true
        liveControlSliderView.heightAnchor.constraint(equalToConstant: (pView.frame.height / 4)).isActive = true
        
        //Slider
        liveControlSlider.translatesAutoresizingMaskIntoConstraints = false
        liveControlSlider.centerYAnchor.constraint(equalTo: liveControlSliderView.centerYAnchor).isActive = true
        liveControlSlider.leftAnchor.constraint(equalTo: liveControlSliderView.leftAnchor, constant: 5).isActive = true
        liveControlSlider.rightAnchor.constraint(equalTo: liveControlGoLive.leftAnchor, constant: -10).isActive = true
        
        
        //Got to Live Button
        liveControlGoLive.translatesAutoresizingMaskIntoConstraints = false
        liveControlGoLive.centerYAnchor.constraint(equalTo: liveControlSliderView.centerYAnchor).isActive = true
        liveControlGoLive.rightAnchor.constraint(equalTo: liveControlSliderView.rightAnchor, constant: -10).isActive = true
        
        
    }
    
    @objc private func seekPlayAction() {
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
    
    public func hideControls(){
        playPauseButton.isHidden = true
        liveControlSliderView.isHidden = true
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("view tapped")
        resetTimer()
        seekControls()
    }
    
    @objc private func goToDirectAction(){
        avPlayer.seek(to: CMTime.positiveInfinity)
        avPlayer.play()
        print("go to direct")
    }
    
//    private func setGoToLiveButtonImage(){
//        if(avPlayer.)
//    }
    
    private func activateTimer(){
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(disableControls), userInfo: nil, repeats: false)
    }
    
    @objc func disableControls() {
        seekControls()
    }
    
    private func resetTimer(){
        timer?.invalidate()
        timer = nil
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
        
        if(!liveControlSliderView.isHidden){
            UIView.animate(withDuration: 0.2, animations: {
                self.liveControlSliderView.alpha = 0
            }) { (finished) in
                self.liveControlSliderView.isHidden = finished
            }
        }else{
            self.liveControlSliderView.alpha = 0
            self.liveControlSliderView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.liveControlSliderView.alpha = 1
            }
            activateTimer()
        }
    }
}
