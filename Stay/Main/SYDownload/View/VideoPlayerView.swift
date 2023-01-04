//
//  VideoPlayerView.swift
//  Stay
//
//  Created by King on 14/12/2022.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    private var player: AVPlayer?
    private var itemOb: NSKeyValueObservation?
    private var itemStatusOb: NSKeyValueObservation?
    private var timeOb: Any?
    
    private let allResources: [DownloadResource]
    private weak var controller: UIViewController?
    
    init(reseources: [DownloadResource], controller: UIViewController? = nil) {
        allResources = reseources
        self.controller = controller
        player = AVPlayer()
        
        super.init(frame: .zero)
        backgroundColor = .black
        setupControls()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction)))
        resetControlHide()
        
        playerLayer.player = player
        avPipController = AVPictureInPictureController(playerLayer: playerLayer)
        
//        itemOb = player?.observe(\.currentItem) { [weak self] player, _ in
//            if player.items().count == 1 {
//                self?.addAllVideosToPlayer()
//            }
//        }
        itemStatusOb = player?.observe(\AVQueuePlayer.currentItem?.status) { [weak self] _, _ in
            if let currentItem = self?.player?.currentItem {
                if currentItem.status == .readyToPlay {
                    self?.remainLabel.text = currentItem.duration.positionalTime
                } else {
                    self?.remainLabel.text = "00:00"
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onVolumeChanged), name: NSNotification.Name(rawValue: "SystemVolumeDidChange"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(toggleControls), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideVolumeView), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func removeFromSuperview() {
        player?.pause()
        
        super.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        if mpVolumeView.superview == nil {
            mpVolumeView.alpha = 0.001
            self.window?.insertSubview(mpVolumeView, at: 0)
        }
        showControls(isLandscape: UIApplication.shared.statusBarOrientation.isLandscape)
        (controller as? PlayerViewController)?.updateViewState(isLandscape: UIApplication.shared.statusBarOrientation.isLandscape)
        
        super.layoutSubviews()
    }
    
    func addPeriodicTimeObserver() {
        guard self.timeOb == nil else { return }
        
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeOb = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let currentItem = self?.player?.currentItem else { return }
            if self?.isSliding == false {
                self?.seekBar.setValue(Float(time.seconds / currentItem.duration.seconds), animated: false)
            }
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
    
    @objc
    func playerDidFinishPlaying() {
        nextAction()
    }
    
    @objc
    func onVolumeChanged(note: Notification) {
        if (note.userInfo?["Reason"] as? String) == "ExplicitVolumeChange" {
            DispatchQueue.main.async {
                self.volumeView.isHidden = false
                let (volumeImage, volumeValue) = self.getVolume()
                self.volumeIcon.image = volumeImage
                self.volumePV.progress = volumeValue
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideVolumeView), object: nil)
                self.perform(#selector(self.hideVolumeView), with: nil, afterDelay: 1.2)
            }
        }
    }
    
    @objc
    func hideVolumeView() {
        volumeView.isHidden = true
    }

    var currIndex = -1
    private var currResource: DownloadResource {
        allResources[currIndex]
    }
    
    var isControlsShow = true
    let backBtn = UIButton()
    let titleLabel = UILabel()
    let airBtn = AVRoutePickerView()
    let pipBtn = UIButton()
    let lockBtn = UIButton()
    let playBtn = UIButton()
    let prevBtn = UIButton()
    let nextBtn = UIButton()
    let currLabel = UILabel()
    let seekBar = UISlider()
    let remainLabel = UILabel()
    let modeBtn = UIButton()
    let rightBottomView = UIStackView()
    let brightnessView = UIView()
    let brightnessPV = UIProgressView()
    let volumeView = UIView()
    let volumeIcon = UIImageView()
    let volumePV = UIProgressView()
    let progressView = UIView()
    let progressLabel = UILabel()
    let progressPV = UIProgressView()
    let rateView = UIView()
    let qualityLabel = UILabel()
    func setupControls() {
        backBtn.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        airBtn.tintColor = .white
        airBtn.prioritizesVideoDevices = true
        airBtn.translatesAutoresizingMaskIntoConstraints = false
        pipBtn.setImage(UIImage(systemName: "pip.enter", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        pipBtn.addTarget(self, action: #selector(pipAction), for: .touchUpInside)
        pipBtn.translatesAutoresizingMaskIntoConstraints = false
        
        brightnessView.isHidden = true
        brightnessView.layer.cornerRadius = 8
        brightnessView.clipsToBounds = true
        brightnessView.backgroundColor = .black.withAlphaComponent(0.1)
        brightnessView.translatesAutoresizingMaskIntoConstraints = false
        let brightIcon = UIImageView(image: UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal))
        brightIcon.translatesAutoresizingMaskIntoConstraints = false
        brightnessView.addSubview(brightIcon)
        brightnessPV.tintColor = .white
        brightnessPV.progress = Float(UIScreen.main.brightness)
        brightnessPV.translatesAutoresizingMaskIntoConstraints = false
        brightnessView.addSubview(brightnessPV)
        
        volumeView.isHidden = true
        volumeView.layer.cornerRadius = 8
        volumeView.clipsToBounds = true
        volumeView.backgroundColor = .black.withAlphaComponent(0.1)
        volumeView.translatesAutoresizingMaskIntoConstraints = false
//        let (volumeImage, volumeValue) = getVolume()
//        volumeIcon.image = volumeImage
        volumeIcon.translatesAutoresizingMaskIntoConstraints = false
        volumeView.addSubview(volumeIcon)
        volumePV.tintColor = .white
//        volumePV.progress = volumeValue
        volumePV.translatesAutoresizingMaskIntoConstraints = false
        volumeView.addSubview(volumePV)
        
        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = .systemFont(ofSize: 28)
        progressLabel.textColor = .white
        progressLabel.text = "00:00"
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressLabel)
        progressPV.tintColor = .white
        progressPV.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressPV)
        
        NSLayoutConstraint.activate([
            brightIcon.leadingAnchor.constraint(equalTo: brightnessView.leadingAnchor, constant: 5),
            brightIcon.centerYAnchor.constraint(equalTo: brightnessView.centerYAnchor),
            brightnessPV.leadingAnchor.constraint(equalTo: brightIcon.trailingAnchor, constant: 5),
            brightnessPV.trailingAnchor.constraint(equalTo: brightnessView.trailingAnchor, constant: -5),
            brightnessPV.centerYAnchor.constraint(equalTo: brightnessView.centerYAnchor),
            
            volumeIcon.leadingAnchor.constraint(equalTo: volumeView.leadingAnchor, constant: 5),
            volumeIcon.centerYAnchor.constraint(equalTo: volumeView.centerYAnchor),
            volumePV.leadingAnchor.constraint(equalTo: volumeIcon.trailingAnchor, constant: 5),
            volumePV.trailingAnchor.constraint(equalTo: volumeView.trailingAnchor, constant: -5),
            volumePV.centerYAnchor.constraint(equalTo: volumeView.centerYAnchor),
            
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 5),
            progressPV.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressPV.widthAnchor.constraint(equalToConstant: 100),
            progressPV.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -5),
        ])
        
        playBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        playBtn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        currLabel.font = FCStyle.footnote
        currLabel.textColor = .white
        currLabel.text = "00:00"
        currLabel.textAlignment = .center
        currLabel.translatesAutoresizingMaskIntoConstraints = false
        seekBar.tintColor = .white
        seekBar.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 10)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        seekBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        remainLabel.font = FCStyle.footnote
        remainLabel.textColor = .white
        remainLabel.text = "00:00"
        remainLabel.textAlignment = .center
        remainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        modeBtn.setImage(UIImage(named: "LandModeIcon"), for: .normal)
        modeBtn.addTarget(self, action: #selector(modeAction), for: .touchUpInside)
        modeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        
        titleLabel.font = FCStyle.bodyBold
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lockBtn.setImage(UIImage(systemName: "lock.open", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        lockBtn.addTarget(self, action: #selector(lockAction), for: .touchUpInside)
        lockBtn.translatesAutoresizingMaskIntoConstraints = false
        prevBtn.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        prevBtn.addTarget(self, action: #selector(prevAction), for: .touchUpInside)
        prevBtn.translatesAutoresizingMaskIntoConstraints = false
        nextBtn.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        rightBottomView.axis = .horizontal
        rightBottomView.alignment = .center
        rightBottomView.spacing = 15
        rightBottomView.translatesAutoresizingMaskIntoConstraints = false
        let rateBtn = UIButton()
        rateBtn.setTitle("倍速", for: .normal)
        rateBtn.titleLabel?.font = FCStyle.footnote
        rateBtn.setTitleColor(.white, for: .normal)
        rateBtn.addTarget(self, action: #selector(rateAction), for: .touchUpInside)
        rightBottomView.addArrangedSubview(rateBtn)
        qualityLabel.layer.cornerRadius = 5
        qualityLabel.clipsToBounds = true
        qualityLabel.layer.borderWidth = 1.5
        qualityLabel.layer.borderColor = UIColor.white.cgColor
        qualityLabel.font = FCStyle.footnote
        qualityLabel.textColor = .white
        rightBottomView.addArrangedSubview(qualityLabel)
    }
    
    func showControls(isLandscape: Bool) {
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        addSubview(backBtn)
        addSubview(airBtn)
        addSubview(pipBtn)
        
        addSubview(brightnessView)
        addSubview(volumeView)
        addSubview(progressView)
        
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
            airBtn.widthAnchor.constraint(equalToConstant: 40),
            airBtn.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            airBtn.heightAnchor.constraint(equalToConstant: 40),
            
            brightnessView.centerXAnchor.constraint(equalTo: centerXAnchor),
            brightnessView.widthAnchor.constraint(equalToConstant: 120),
            brightnessView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            brightnessView.heightAnchor.constraint(equalToConstant: 30),
            
            volumeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            volumeView.widthAnchor.constraint(equalToConstant: 120),
            volumeView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            volumeView.heightAnchor.constraint(equalToConstant: 30),
            
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 120),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        addSubview(playBtn)
        addSubview(currLabel)
        addSubview(seekBar)
        addSubview(remainLabel)
        
        if isLandscape {
            addSubview(titleLabel)
            addSubview(lockBtn)
            addSubview(prevBtn)
            addSubview(nextBtn)
            addSubview(rightBottomView)
//            addSubview(rateView)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 0),
                titleLabel.widthAnchor.constraint(equalToConstant: 260),
                titleLabel.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
                
                lockBtn.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
                lockBtn.widthAnchor.constraint(equalToConstant: 30),
                lockBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
                lockBtn.heightAnchor.constraint(equalToConstant: 48),
                
                prevBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                prevBtn.widthAnchor.constraint(equalToConstant: 30),
                prevBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                prevBtn.heightAnchor.constraint(equalToConstant: 48),
                playBtn.leadingAnchor.constraint(equalTo: prevBtn.trailingAnchor, constant: 0),
                playBtn.widthAnchor.constraint(equalToConstant: 30),
                playBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                playBtn.heightAnchor.constraint(equalToConstant: 48),
                nextBtn.leadingAnchor.constraint(equalTo: playBtn.trailingAnchor, constant: 0),
                nextBtn.widthAnchor.constraint(equalToConstant: 30),
                nextBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                nextBtn.heightAnchor.constraint(equalToConstant: 48),
                currLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                currLabel.widthAnchor.constraint(equalToConstant: 60),
                currLabel.bottomAnchor.constraint(equalTo: prevBtn.topAnchor, constant: 0),
                remainLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                remainLabel.widthAnchor.constraint(equalToConstant: 55),
                remainLabel.centerYAnchor.constraint(equalTo: currLabel.centerYAnchor),
                seekBar.leadingAnchor.constraint(equalTo: currLabel.trailingAnchor, constant: 4),
                seekBar.trailingAnchor.constraint(equalTo: remainLabel.leadingAnchor, constant: -4),
                seekBar.centerYAnchor.constraint(equalTo: currLabel.centerYAnchor),
                rightBottomView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                rightBottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13),
                
            ])
        } else {
            addSubview(modeBtn)
            
            NSLayoutConstraint.activate([
                
                playBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                playBtn.widthAnchor.constraint(equalToConstant: 30),
                playBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                playBtn.heightAnchor.constraint(equalToConstant: 48),
                currLabel.leadingAnchor.constraint(equalTo: playBtn.trailingAnchor, constant: 0),
                currLabel.widthAnchor.constraint(equalToConstant: 60),
                currLabel.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
                modeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                modeBtn.widthAnchor.constraint(equalToConstant: 40),
                modeBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                modeBtn.heightAnchor.constraint(equalToConstant: 50),
                remainLabel.trailingAnchor.constraint(equalTo: modeBtn.leadingAnchor, constant: 0),
                remainLabel.widthAnchor.constraint(equalToConstant: 55),
                remainLabel.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
                seekBar.leadingAnchor.constraint(equalTo: currLabel.trailingAnchor, constant: 4),
                seekBar.trailingAnchor.constraint(equalTo: remainLabel.leadingAnchor, constant: -4),
                seekBar.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
                
            ])
        }
    }
    
    let mpVolumeView = MPVolumeView()
    var volumeSlider: UISlider?
    func getVolume() -> (UIImage, Float) {
        if volumeSlider == nil {
            volumeSlider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        }
        let volumeValue = volumeSlider?.value ?? 0
        
        return (getVolumeImage(volumeValue), volumeValue)
    }
    
    func getVolumeImage(_ value: Float) -> UIImage {
        var iconName = "speaker.fill"
        if value > 0.6 {
            iconName = "speaker.wave.3"
        } else if value > 0.3 {
            iconName = "speaker.wave.2"
        } else if value > 0 {
            iconName = "speaker.wave.1"
        }
        
        return UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))!.withTintColor(.white).withRenderingMode(.alwaysOriginal)
    }
    
    func setVolume(_ value: Float) {
        if volumeSlider == nil {
            volumeSlider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.volumeSlider?.value = value
        }
    }
    
    @objc
    func backAction() {
        if UIApplication.shared.statusBarOrientation.isLandscape {
            if #available(iOS 16.0, *) {
                controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            return
        }
        if let currentTime = player?.currentTime() {
            DataManager.share().updateWatchProgress(Int(currentTime.roundedSeconds), uuid: self.currResource.downloadUuid)
        }
        controller?.navigationController?.popViewController(animated: true)
        controller = nil
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
            playBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            player?.pause()
            playBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @objc
    func prevAction() {
        resetControlHide()
        if currIndex > 0 {
            play(index: currIndex - 1)
        }
    }
    
    @objc
    func nextAction() {
        resetControlHide()
        if currIndex < allResources.count - 1 {
            play(index: currIndex + 1)
        }
    }
    
    var isSliding = false
    @objc
    func onSliderValChanged(slider: UISlider, event: UIEvent) {
        resetControlHide()
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isSliding = true
            case .moved:
                break
            case .ended:
                if let currentItem = player?.currentItem {
                    player?.seek(to: CMTime(seconds: currentItem.duration.seconds * Double(slider.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] _ in
                        self?.isSliding = false
                        if let time = self?.player?.currentTime(), let currentItem = self?.player?.currentItem {
                            self?.seekBar.setValue(Float(time.seconds / currentItem.duration.seconds), animated: false)
                            self?.currLabel.text = time.positionalTime
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    @objc
    func modeAction() {
        resetControlHide()
        if #available(iOS 16.0, *) {
            controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    var isLocked = false
    @objc
    func lockAction() {
        isLocked = !isLocked
        lockBtn.setImage(UIImage(systemName: isLocked ? "lock" : "lock.open", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        
        toggleControls()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = isLocked ? UIInterfaceOrientationMask.landscape : UIInterfaceOrientationMask.all
        }
    }
    
    @objc
    func rateAction() {
        
    }
    
    @objc
    func tapAction() {
        if isLocked {
            lockBtn.isHidden = false
            return
        }
        
        toggleControls()
    }
    
    var normalRate: Float = 0.0
    @objc
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if isLocked {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            normalRate = player?.rate ?? 0.0
            let location = gestureRecognizer.location(in: self)
            player?.rate = location.x > self.frame.width / 2 ? (normalRate * 2) : (normalRate / 2)
        case .ended, .failed, .cancelled:
            player?.rate = normalRate
        default:
            break
        }
    }
    
    var mode = -1
    var startValue = 0.0
    var startTime = CMTime(seconds: 0, preferredTimescale: 1)
    @objc
    func panAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        if isLocked {
            return
        }
        
        let translation = gestureRecognizer.translation(in: self)
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            if mode == -1 {
                if abs(translation.y) > abs(translation.x) {
                    let location = gestureRecognizer.location(in: self)
                    if location.x < self.frame.width / 2 {
                        mode = 0
                        startValue = UIScreen.main.brightness
                        brightnessView.isHidden = false
                    } else {
                        mode = 1
                        startValue = Double(getVolume().1)
                        volumeView.isHidden = false
                    }
                } else {
                    mode = 2
                    startTime = player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)
                    progressLabel.text = startTime.positionalTime
                    progressPV.progress = seekBar.value
                    progressView.isHidden = false
                }
            } else {
                switch mode {
                case 0:
                    brightnessPV.progress = Float(max(0, min(1, startValue - translation.y / 100.0)))
                    UIScreen.main.brightness = CGFloat(brightnessPV.progress)
                case 1:
                    let volumeValue = Float(max(0, min(1, startValue - translation.y / 100.0)))
                    setVolume(volumeValue)
                    volumeIcon.image = getVolumeImage(volumeValue)
                    volumePV.progress = volumeValue
                case 2:
                    let interval = max(0, min(player?.currentItem?.duration.seconds ?? 0, startTime.seconds + translation.x))
                    progressLabel.text = CMTime(seconds: interval, preferredTimescale: 1).positionalTime
                    if let duration = player?.currentItem?.duration.seconds {
                        progressPV.progress =  Float(interval / duration)
                    } else {
                        progressPV.progress = 0
                    }
                default:
                    break
                }
            }
        default:
            switch mode {
            case 0:
                brightnessView.isHidden = true
            case 1:
                volumeView.isHidden = true
            case 2:
                if let currentItem = player?.currentItem {
                    player?.seek(to: CMTime(seconds: currentItem.duration.seconds * Double(progressPV.progress), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                }
                progressView.isHidden = true
            default:
                break
            }
            mode = -1
        }
    }
    
    @objc
    func toggleControls() {
        if (isControlsShow) {
            backBtn.isHidden = true
            titleLabel.isHidden = true
            lockBtn.isHidden = true
            airBtn.isHidden = true
            pipBtn.isHidden = true
            playBtn.isHidden = true
            currLabel.isHidden = true
            seekBar.isHidden = true
            remainLabel.isHidden = true
            modeBtn.isHidden = true
            prevBtn.isHidden = true
            nextBtn.isHidden = true
            rightBottomView.isHidden = true
            isControlsShow = false
        } else {
            backBtn.isHidden = false
            titleLabel.isHidden = false
            lockBtn.isHidden = false
            airBtn.isHidden = false
            pipBtn.isHidden = false
            playBtn.isHidden = false
            currLabel.isHidden = false
            seekBar.isHidden = false
            remainLabel.isHidden = false
            modeBtn.isHidden = false
            prevBtn.isHidden = false
            nextBtn.isHidden = false
            rightBottomView.isHidden = false
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
    
    func pause() {
        player?.pause()
        removePeriodicTimeObserver()
    }
    
    func play() {
        player?.play()
        addPeriodicTimeObserver()
    }
    
    func play(index: Int) {
        if currIndex != index {
            if currIndex != -1, let currentTime = player?.currentTime() {
                currResource.watchProcess = Int(currentTime.roundedSeconds)
                DataManager.share().updateWatchProgress(currResource.watchProcess, uuid: self.currResource.downloadUuid)
            }
            currIndex = index
            titleLabel.text = currResource.title
            (controller as? PlayerViewController)?.refreshCurrVideo()
            let asset = AVURLAsset(url: URL(fileURLWithPath: currResource.allPath))
            let item = AVPlayerItem(asset: asset)
            player?.replaceCurrentItem(with: item)
            if currResource.watchProcess > 0 {
                player?.seek(to: CMTime(seconds: Double(currResource.watchProcess), preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { _ in
                    self.play()
                }
            } else {
                self.play()
            }
        }
    }

    func setRate(_ value: Float) {
        player?.rate = value
    }
    
    func cleanup() {
        player?.pause()
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
