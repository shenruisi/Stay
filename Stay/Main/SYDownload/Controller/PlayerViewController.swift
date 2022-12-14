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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let videoView = VideoPlayerView(urls: [URL(fileURLWithPath: resource.allPath)], controller: self)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        
        let container = UIView()
        container.backgroundColor = FCStyle.background
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0 / 16),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: videoView.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        videoView.play()
    }

}
