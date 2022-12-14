//
//  FolderSlideController.swift
//  Stay
//
//  Created by Jin on 2022/11/27.
//

import UIKit

class FolderSlideController: FCSlideController {

    var folderTab: FCTab?
    var gotoNavController: ModalNavigationController
    @objc
    init(folderTab: FCTab?) {
        self.folderTab = folderTab
        let modalViewController = FolderModalController(folderTab: folderTab)
        modalViewController.hideNavigationBar = true
        self.gotoNavController = ModalNavigationController(rootModalViewController: modalViewController)
        
        super.init()
        self.gotoNavController.slideController = self
    }
    
    override func marginToFrom() -> CGFloat {
        return 30
    }
    
    override func modalNavigationController() -> ModalNavigationController {
        return gotoNavController
    }
    
}
