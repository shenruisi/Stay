//
//  SYNotesViewController.h
//  Stay
//
//  Created by zly on 2022/3/18.
//

#import <UIKit/UIKit.h>

#ifdef FC_MAC
#import "NavigateViewController.h"
@interface SYNotesViewController : NavigateViewController
#else
@interface SYNotesViewController : UIViewController
#endif

@property (nonatomic, copy) NSArray<NSString*> *notes;

@end

