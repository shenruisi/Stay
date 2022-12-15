//
//  VideoPlayerView.swift
//  Stay
//
//  Created by King on 14/12/2022.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    private var player: AVQueuePlayer?
    private var itemOb: NSKeyValueObservation?
    private var itemStatusOb: NSKeyValueObservation?
    private var timeOb: Any?
    
    private let allURLs: [URL]
    private let controller: UIViewController?
    
    init(urls: [URL], controller: UIViewController? = nil) {
        allURLs = urls
        self.controller = controller
        player = AVQueuePlayer()
        
        super.init(frame: .zero)
        backgroundColor = .black
        setupControls()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        resetControlHide()
        
        addAllVideosToPlayer()
        
        playerLayer.player = player
        avPipController = AVPictureInPictureController(playerLayer: playerLayer)
        
        itemOb = player?.observe(\.currentItem) { [weak self] player, _ in
            if player.items().count == 1 {
                self?.addAllVideosToPlayer()
            }
        }
        itemStatusOb = player?.observe(\AVQueuePlayer.currentItem?.status) { [weak self] _, _ in
            if let currentItem = self?.player?.currentItem {
                if currentItem.status == .readyToPlay {
                    self?.remainLabel.text = currentItem.duration.positionalTime
                } else {
                    self?.remainLabel.text = "00:00"
                }
            }
        }
        addPeriodicTimeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(toggleControls), object: nil)
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeOb = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let currentItem = self?.player?.currentItem else { return }
            self?.seekBar.setValue(Float(time.seconds / currentItem.duration.seconds) , animated: true)
            self?.currLabel.text = time.positionalTime
//            self?.remainLabel.text = currentItem.duration.positionalTime
//            self?.remainLabel.text = (currentItem.duration - time).positionalTime
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeOb {
            player?.removeTimeObserver(timeObserverToken)
            self.timeOb = nil
        }
    }

    private func addAllVideosToPlayer() {
        for url in allURLs {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player?.insert(item, after: player?.items().last)
        }
    }
    
    var isControlsShow = true
    let backBtn = UIButton()
    let airBtn = AVRoutePickerView()
    let pipBtn = UIButton()
    let playBtn = UIButton()
    let currLabel = UILabel()
    let seekBar = UISlider()
    let remainLabel = UILabel()
    let modeBtn = UIButton()
    func setupControls() {
        backBtn.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backBtn)
        
        airBtn.tintColor = .white
        airBtn.prioritizesVideoDevices = true
        airBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(airBtn)
        pipBtn.setImage(UIImage(systemName: "pip.enter", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        pipBtn.addTarget(self, action: #selector(pipAction), for: .touchUpInside)
        pipBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pipBtn)
        
        playBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        playBtn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playBtn)
        currLabel.font = FCStyle.footnote
        currLabel.textColor = .white
        currLabel.text = "00:00"
        currLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currLabel)
        seekBar.tintColor = .white
        seekBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(seekBar)
        remainLabel.font = FCStyle.footnote
        remainLabel.textColor = .white
        remainLabel.text = "00:00"
        remainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(remainLabel)
        modeBtn.setImage(UIImage(systemName: "iphone", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        modeBtn.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        modeBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(modeBtn)
        
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            backBtn.widthAnchor.constraint(equalToConstant: 48),
            backBtn.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            backBtn.heightAnchor.constraint(equalToConstant: 48),
            
            pipBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            pipBtn.widthAnchor.constraint(equalToConstant: 50),
            pipBtn.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            pipBtn.heightAnchor.constraint(equalToConstant: 50),
            airBtn.trailingAnchor.constraint(equalTo: pipBtn.leadingAnchor, constant: 0),
            airBtn.widthAnchor.constraint(equalToConstant: 50),
            airBtn.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            airBtn.heightAnchor.constraint(equalToConstant: 50),
            
            playBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            playBtn.widthAnchor.constraint(equalToConstant: 48),
            playBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            playBtn.heightAnchor.constraint(equalToConstant: 48),
            currLabel.leadingAnchor.constraint(equalTo: playBtn.trailingAnchor, constant: 0),
            currLabel.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
            modeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            modeBtn.widthAnchor.constraint(equalToConstant: 50),
            modeBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            modeBtn.heightAnchor.constraint(equalToConstant: 50),
            remainLabel.trailingAnchor.constraint(equalTo: modeBtn.leadingAnchor, constant: 0),
            remainLabel.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
            seekBar.leadingAnchor.constraint(equalTo: currLabel.trailingAnchor, constant: 8),
            seekBar.trailingAnchor.constraint(equalTo: remainLabel.leadingAnchor, constant: -8),
            seekBar.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
        ])
    }
    
    @objc
    func backAction() {
        controller?.dismiss(animated: true, completion: nil)
    }
    
    var avPipController: AVPictureInPictureController?
    @objc
    func pipAction() {
        resetControlHide()
        if AVPictureInPictureController.isPictureInPictureSupported() {
            if avPipController?.isPictureInPictureActive != true {
                avPipController?.startPictureInPicture()
            }
        } else {
            
        }
    }
    
    @objc
    func playAction() {
        resetControlHide()
        if player?.rate == 0 {
            player?.play()
            playBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            player?.pause()
            playBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @objc
    func onSliderValChanged(slider: UISlider, event: UIEvent) {
        resetControlHide()
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                player?.pause()
            case .moved:
                break
            case .ended:
                if let currentItem = player?.currentItem {
                    player?.seek(to: CMTime(seconds: currentItem.duration.seconds * Double(slider.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                    player?.play()
                }
            default:
                break
            }
        }
    }
    
    @objc
    func modeAction() {
        resetControlHide()
        print("modeAction")
    }
    
    @objc
    func tapAction() {
        toggleControls()
    }
    
    @objc
    func toggleControls() {
        if (isControlsShow) {
            backBtn.isHidden = true
            airBtn.isHidden = true
            pipBtn.isHidden = true
            playBtn.isHidden = true
            currLabel.isHidden = true
            seekBar.isHidden = true
            remainLabel.isHidden = true
            modeBtn.isHidden = true
            isControlsShow = false
        } else {
            backBtn.isHidden = false
            airBtn.isHidden = false
            pipBtn.isHidden = false
            playBtn.isHidden = false
            currLabel.isHidden = false
            seekBar.isHidden = false
            remainLabel.isHidden = false
            modeBtn.isHidden = false
            isControlsShow = true
        }
        resetControlHide()
    }
    
    func resetControlHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(toggleControls), object: nil)
        if (isControlsShow) {
            perform(#selector(toggleControls), with: nil, afterDelay: 5)
        }
    }
    
    func play() {
        player?.play()
    }
    
    func setVolume(_ value: Float) {
        player?.volume = value
    }
    
    func setRate(_ value: Float) {
        player?.rate = value
    }
    
    func cleanup() {
        player?.pause()
        player?.removeAllItems()
        player = nil
    }
    
}

extension CMTime {
    var roundedSeconds: TimeInterval {
        guard !(seconds.isInfinite || seconds.isNaN) else { return 0 }
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
