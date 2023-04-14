//
//  UpgradeModalViewController.m
//  Stay
//
//  Created by ris on 2023/4/14.
//

#import "UpgradeModalViewController.h"
#import "FCApp.h"

@interface UpgradeModalViewController()

@end

@implementation UpgradeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}


- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 350);
}

@end
