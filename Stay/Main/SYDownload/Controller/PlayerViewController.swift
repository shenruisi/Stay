//
//  PlayerViewController.swift
//  Stay
//
//  Created by King on 28/11/2022.
//

import UIKit

@objc
class PlayerViewController: UIViewController {
    
    let resource: DownloadResource
    @objc
    init(resource: DownloadResource) {
        self.resource = resource
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
       return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FCStyle.background

        let videoView = VideoPlayerView(urls: [URL(fileURLWithPath: resource.allPath)], controller: self)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0 / 16),
        ])
        
        videoView.play()
    }

}
