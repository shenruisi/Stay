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

class VideoPlayerView: UIView, AVPictureInPictureControllerDelegate, AVRoutePickerViewDelegate {
    
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
    
    var allResources: [DownloadResource]
    weak var controller: PlayerViewController?
    
    init(resources: [DownloadResource], controller: PlayerViewController? = nil) {
        allResources = resources
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
        avPipController?.delegate = self

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
        if currIndex != -1, let currentTime = player?.currentTime() {
            currResource.watchProcess = Int(currentTime.roundedSeconds)
            DataManager.share().updateWatchProgress(currResource.watchProcess, uuid: self.currResource.downloadUuid)
        }
        player?.pause()
        
        super.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        #if FC_IOS
        if mpVolumeView.superview == nil {
            mpVolumeView.alpha = 0.001
            self.window?.insertSubview(mpVolumeView, at: 0)
        }
        #endif
        showControls(isLandscape: isLandscapeMode)
        controller?.updateViewState(isLandscape: isLandscapeMode)
        
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
            let volume = note.userInfo?["Volume"] as? Float
            DispatchQueue.main.async {
                self.volumeView.isHidden = false
                let (volumeImage, volumeValue) = volume != nil ? (self.getVolumeImage(volume!), volume!) : self.getVolume()
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
    
    var isLandscapeMode: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIApplication.shared.statusBarOrientation.isLandscape
        } else {
            #if FC_IOS
            return controller?.isSecondaryMode() ?? true
            #else
            return true
            #endif
        }
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
    let fullBtn = UIButton()
    let rightBottomView = UIStackView()
    let rateBtn = UIButton()
    let brightnessView = UIView()
    let brightnessPV = UIProgressView()
    let volumeView = UIView()
    let volumeIcon = UIImageView()
    let volumePV = UIProgressView()
    let progressView = UIView()
    let progressLabel = UILabel()
    let progressPV = UIProgressView()
    let forwardView = UIView()
    let backwardView = UIView()
    let rateView = UIView()
    let qualityLabel = UILabel()
    func setupControls() {
        backBtn.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        airBtn.tintColor = .white
        airBtn.prioritizesVideoDevices = true
        airBtn.delegate = self
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
        let (volumeImage, volumeValue) = getVolume()
        volumeIcon.image = volumeImage
        volumeIcon.translatesAutoresizingMaskIntoConstraints = false
        volumeView.addSubview(volumeIcon)
        volumePV.tintColor = .white
        volumePV.progress = volumeValue
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
        
        forwardView.isHidden = true
        forwardView.translatesAutoresizingMaskIntoConstraints = false
        let forwardImg = UIImageView(image: UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal))
        forwardImg.translatesAutoresizingMaskIntoConstraints = false
        forwardView.addSubview(forwardImg)
        backwardView.isHidden = true
        backwardView.translatesAutoresizingMaskIntoConstraints = false
        let backwardImg = UIImageView(image: UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal))
        backwardImg.translatesAutoresizingMaskIntoConstraints = false
        backwardView.addSubview(backwardImg)
        
        rateView.isHidden = true
        rateView.translatesAutoresizingMaskIntoConstraints = false
        let rWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 10
        let rWidthS = 1.125 * rWidth
        for (i, rate) in rates.enumerated() {
            let rView = UIButton()
            rView.tag = i
            rView.layer.cornerRadius = 8
            rView.clipsToBounds = true
            rView.backgroundColor = .black.withAlphaComponent(0.1)
            rView.addTarget(self, action: #selector(rateControlAction), for: .touchUpInside)
            rView.translatesAutoresizingMaskIntoConstraints = false
            rateView.addSubview(rView)
            let rLabel = UILabel()
            rLabel.font = FCStyle.bodyBold
            rLabel.textColor = .white
            rLabel.text = "\(rate)X"
            rLabel.translatesAutoresizingMaskIntoConstraints = false
            rView.addSubview(rLabel)
            let flagView = UIView()
            flagView.isHidden = i != 2
            flagView.backgroundColor = .white
            flagView.translatesAutoresizingMaskIntoConstraints = false
            rView.addSubview(flagView)
            
            NSLayoutConstraint.activate([
                rView.leadingAnchor.constraint(equalTo: rateView.leadingAnchor, constant: rWidthS * CGFloat((i + 1))),
                rView.widthAnchor.constraint(equalToConstant: rWidth),
                rView.centerYAnchor.constraint(equalTo: rateView.centerYAnchor),
                rView.heightAnchor.constraint(equalToConstant: rWidth),
                rLabel.centerXAnchor.constraint(equalTo: rView.centerXAnchor),
                rLabel.centerYAnchor.constraint(equalTo: rView.centerYAnchor),
                flagView.leadingAnchor.constraint(equalTo: rView.leadingAnchor),
                flagView.trailingAnchor.constraint(equalTo: rView.trailingAnchor),
                flagView.bottomAnchor.constraint(equalTo: rView.bottomAnchor),
                flagView.heightAnchor.constraint(equalToConstant: 4),
            ])
        }
        
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
            
            forwardImg.leadingAnchor.constraint(equalTo: forwardView.leadingAnchor),
            forwardImg.centerYAnchor.constraint(equalTo: forwardView.centerYAnchor),
            backwardImg.leadingAnchor.constraint(equalTo: backwardView.leadingAnchor),
            backwardImg.centerYAnchor.constraint(equalTo: backwardView.centerYAnchor),
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
        #if FC_IOS
        seekBar.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 10)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        #endif
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
        fullBtn.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        fullBtn.addTarget(self, action: #selector(fullAction), for: .touchUpInside)
        fullBtn.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = FCStyle.bodyBold
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lockBtn.setImage(UIImage(systemName: "lock.open", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
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
        rateBtn.setTitle(NSLocalizedString("Rate", comment: ""), for: .normal)
        rateBtn.titleLabel?.font = FCStyle.footnote
        rateBtn.setTitleColor(.white, for: .normal)
        rateBtn.addTarget(self, action: #selector(rateBtnAction), for: .touchUpInside)
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
        
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        
        addSubview(backBtn)
        addSubview(airBtn)
        addSubview(pipBtn)
        
        addSubview(brightnessView)
        addSubview(volumeView)
        addSubview(progressView)
        addSubview(forwardView)
        addSubview(backwardView)
        
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            backBtn.widthAnchor.constraint(equalToConstant: (isPhone || !isLandscape) ? 48 : 0),
            backBtn.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            backBtn.heightAnchor.constraint(equalToConstant: 48),
            
            pipBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            pipBtn.widthAnchor.constraint(equalToConstant: (isPhone || !isLandscape) ? 50 : 0),
            pipBtn.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            pipBtn.heightAnchor.constraint(equalToConstant: 50),
            airBtn.trailingAnchor.constraint(equalTo: pipBtn.leadingAnchor, constant: 0),
            airBtn.widthAnchor.constraint(equalToConstant: (isPhone || !isLandscape) ? 40 : 0),
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
            
            forwardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: isLandscape ? -200 : -100),
            forwardView.widthAnchor.constraint(equalToConstant: 50),
            forwardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            forwardView.heightAnchor.constraint(equalToConstant: 30),
            backwardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: isLandscape ? 200 : 100),
            backwardView.widthAnchor.constraint(equalToConstant: 50),
            backwardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backwardView.heightAnchor.constraint(equalToConstant: 30),
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
            addSubview(fullBtn)
            addSubview(rightBottomView)
            addSubview(rateView)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 0),
                titleLabel.widthAnchor.constraint(equalToConstant: isPhone ? 260 : 0),
                titleLabel.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
                
                lockBtn.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
                lockBtn.widthAnchor.constraint(equalToConstant: isPhone ? 30 : 0),
                lockBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
                lockBtn.heightAnchor.constraint(equalToConstant: 48),
                
                rateView.leadingAnchor.constraint(equalTo: leadingAnchor),
                rateView.trailingAnchor.constraint(equalTo: trailingAnchor),
                rateView.topAnchor.constraint(equalTo: topAnchor),
                rateView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
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
                fullBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                fullBtn.widthAnchor.constraint(equalToConstant: !isPhone ? 30 : 0),
                fullBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                fullBtn.heightAnchor.constraint(equalToConstant: 48),
                rightBottomView.trailingAnchor.constraint(equalTo: fullBtn.leadingAnchor, constant: -5),
                rightBottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                rightBottomView.heightAnchor.constraint(equalToConstant: 48),
                
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
                modeBtn.widthAnchor.constraint(equalToConstant: isPhone ? 40 : 0),
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
    
    #if FC_IOS
    let mpVolumeView = MPVolumeView()
    var volumeSlider: UISlider?
    #endif
    func getVolume() -> (UIImage, Float) {
        #if FC_IOS
        if volumeSlider == nil {
            volumeSlider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        }
        let volumeValue = volumeSlider?.value ?? 0
        #else
        let volumeValue = player?.volume ?? 0
        #endif
        
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
        #if FC_IOS
        if volumeSlider == nil {
            volumeSlider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.volumeSlider?.value = value
        }
        #else
        player?.volume = value
        #endif
    }
    
    @objc
    func backAction() {
        if UIDevice.current.userInterfaceIdiom == .phone && isLandscapeMode {
            #if FC_IOS
            if #available(iOS 16.0, *) {
                controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            return
            #endif
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
            addPeriodicTimeObserver()
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
        #if FC_IOS
        if #available(iOS 16.0, *) {
            controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        #endif
    }
    
    @objc
    func fullAction() {
        resetControlHide()
        if UIDevice.current.userInterfaceIdiom != .phone {
            let splitController = QuickAccess.splitController()
            if splitController?.displayMode != .secondaryOnly {
                splitController?.preferredDisplayMode = .secondaryOnly
            } else if splitController?.displayMode == .secondaryOnly {
                splitController?.preferredDisplayMode = .oneBesideSecondary
            }
        }
    }
    
    var isLocked = false
    @objc
    func lockAction() {
        isLocked = !isLocked
        lockBtn.setImage(UIImage(systemName: isLocked ? "lock" : "lock.open", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        
        toggleControls()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = isLocked ? UIInterfaceOrientationMask.landscape : UIInterfaceOrientationMask.all
        }
    }
    
    @objc
    func rateBtnAction() {
        rateView.isHidden = false
    }
    
    let rates: [Float] = [0.5, 0.75, 1, 1.25, 1.5, 2, 3]
    @objc
    func rateControlAction(sender: UIControl) {
        let index = sender.tag
        if index >= 0 && index < rates.count {
            setRate(rates[index])
            for i in 0..<rates.count {
                rateView.subviews[i].subviews[1].isHidden = i != index
            }
            rateBtn.setTitle(index == 2 ? NSLocalizedString("Rate", comment: "") : "\(rates[index])X", for: .normal)
        }
        rateView.isHidden = true
    }
    
    @objc
    func tapAction() {
        if isLocked {
            lockBtn.isHidden = false
            return
        }
        rateView.isHidden = true
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
            if location.x > self.frame.width / 2 {
                player?.rate = normalRate * 2
                forwardView.isHidden = false
                forwardView.subviews[0].startAlpha(duration: 0.5)
            } else {
                player?.rate = -normalRate * 2
                backwardView.isHidden = false
                backwardView.subviews[0].startAlpha(duration: 0.5)
            }
        case .ended, .failed, .cancelled:
            player?.rate = normalRate
            forwardView.isHidden = true
            forwardView.subviews[0].stopAlpha()
            backwardView.isHidden = true
            backwardView.subviews[0].stopAlpha()
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
            fullBtn.isHidden = true
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
            fullBtn.isHidden = false
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
        if currIndex != -1, let currentTime = player?.currentTime() {
            currResource.watchProcess = Int(currentTime.roundedSeconds)
            DataManager.share().updateWatchProgress(currResource.watchProcess, uuid: self.currResource.downloadUuid)
        }
        player?.pause()
        removePeriodicTimeObserver()
        playBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func play() {
        player?.play()
        addPeriodicTimeObserver()
        playBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func play(index: Int) {
        if currIndex != index {
            if currIndex != -1, let currentTime = player?.currentTime() {
                currResource.watchProcess = currentTime == player?.currentItem?.duration ? 0 : Int(currentTime.roundedSeconds)
                DataManager.share().updateWatchProgress(currResource.watchProcess, uuid: self.currResource.downloadUuid)
            }
            currIndex = index
            titleLabel.text = currResource.title
            controller?.refreshCurrVideo()
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
    
    func refreshControls() {
        showControls(isLandscape: isLandscapeMode)
        playBtn.setImage(UIImage(systemName: (player?.rate ?? 0) == 0 ? "play.fill" : "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), for: .normal)
        controller?.updateViewState(isLandscape: isLandscapeMode)
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        refreshControls()
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        refreshControls()
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

extension UIView {
    
    private static let kAlphaAnimationKey = "alphaanimationkey"
    
    @objc
    func startAlpha(duration: Double = 1){
        if layer.animation(forKey: UIView.kAlphaAnimationKey) == nil {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")

            alphaAnimation.fromValue = 0.5
            alphaAnimation.toValue = 1.0
            alphaAnimation.duration = duration
            alphaAnimation.autoreverses = true
            alphaAnimation.repeatCount = Float.infinity

            layer.add(alphaAnimation, forKey: UIView.kAlphaAnimationKey)
        }
    }
    
    @objc
    func stopAlpha(){
        if layer.animation(forKey: UIView.kAlphaAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kAlphaAnimationKey)
        }
    }
    
}
