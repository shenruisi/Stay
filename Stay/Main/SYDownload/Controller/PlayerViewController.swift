//
//  PlayerViewController.swift
//  Stay
//
//  Created by King on 28/11/2022.
//

import UIKit
import AVKit

@objc
class PlayerViewController: SYSecondaryViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static var shared: PlayerViewController?
    
    @objc
    class func controller(resources: [DownloadResource], folderName: String, initIndex: Int) -> PlayerViewController {
        if shared == nil {
            shared = PlayerViewController(resources: resources, folderName: folderName, initIndex: initIndex)
        } else {
            shared?.resources = resources
            shared?.folderName = folderName
            shared?.initIndex = initIndex
            shared?.videoView.allResources = resources
            shared?.videoView.controller = shared
            shared?.videoView.currIndex = -1
            shared?.setRightBarItems()
            shared?.videoView.play(index: initIndex)
        }
        
        return shared!
    }
    
    var resources: [DownloadResource]
    var folderName: String
    var initIndex: Int
    @objc
    init(resources: [DownloadResource], folderName: String, initIndex: Int) {
        self.resources = resources
        self.folderName = folderName
        self.initIndex = initIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    let videoTitleLabel = UILabel()
    let container = UIView()
    let tableView = UITableView()
    var videoView: VideoPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        view.backgroundColor = .black
        
        videoView = VideoPlayerView(resources: resources, controller: self)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        
        container.backgroundColor = FCStyle.secondaryBackground
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        videoTitleLabel.font = FCStyle.bodyBold
        videoTitleLabel.textColor = FCStyle.fcBlack
        videoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(videoTitleLabel)
        
        let line = UIView()
        line.backgroundColor = FCStyle.fcSeparator
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)
        
        let folderNameLabel = UILabel()
        folderNameLabel.font = FCStyle.subHeadlineBold
        folderNameLabel.textColor = FCStyle.fcSecondaryBlack
        folderNameLabel.text = folderName
        folderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(folderNameLabel)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 104.5
        tableView.backgroundColor = FCStyle.secondaryBackground
        tableView.register(SYVideoCellTableViewCell.self, forCellReuseIdentifier: "SYVideoCellTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0 / 16),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: videoView.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.5),
            videoTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.5),
            videoTitleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 13),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.5),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            line.topAnchor.constraint(equalTo: container.topAnchor, constant: 46),
            line.heightAnchor.constraint(equalToConstant: 0.5),
            folderNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.5),
            folderNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.5),
            folderNameLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 46),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        setRightBarItems()
        
        videoView.play(index: initIndex)
        setInteractiveRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.pause()
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setRightBarItems() {
        if isSecondaryMode() {
            let airBtn = AVRoutePickerView()
            airBtn.prioritizesVideoDevices = true
            airBtn.delegate = videoView
            rightBarButtonItems = [UIBarButtonItem(customView: airBtn)]
        } else {
            rightBarButtonItems = []
        }
    }
    
    var popRecognizer: InteractivePopRecognizer?
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    func updateViewState(isLandscape: Bool) {
        container.isHidden = isLandscape
        for constraint in videoView.constraints {
            if constraint.firstAnchor == videoView.heightAnchor {
                videoView.removeConstraint(constraint)
                break
            }
        }
        if isLandscape {
            videoView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        } else {
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0 / 16).isActive = true
        }
    }
    
    func refreshCurrVideo() {
        videoTitleLabel.text = resources[videoView.currIndex].title
        tableView.reloadData()
    }

    func isSecondaryMode() -> Bool {
        return navigationController == nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYVideoCellTableViewCell", for: indexPath) as! SYVideoCellTableViewCell
        cell.selectionStyle = .none
        cell.downloadResource = resources[indexPath.row];
        cell.reload(videoView.currIndex == indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        videoView.play(index: indexPath.row)
    }

}

class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    weak var navigationController: UINavigationController?

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
