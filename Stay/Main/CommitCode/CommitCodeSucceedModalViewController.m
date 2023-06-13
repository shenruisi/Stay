//
//  CommitCodeSucceedModalViewController.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "CommitCodeSucceedModalViewController.h"
#import "FCApp.h"

@implementation CommitCodeSucceedModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}


- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 500);
}

@end
