//
//  SYExpandViewController.h
//  Stay
//
//  Created by zly on 2022/6/16.
//

#import <UIKit/UIKit.h>


#ifdef FC_MAC
#import "NavigateViewController.h"
@interface SYExpandViewController : NavigateViewController
#else
@interface SYExpandViewController : UIViewController
#endif

@property (nonatomic, strong) NSArray *data;

@end


