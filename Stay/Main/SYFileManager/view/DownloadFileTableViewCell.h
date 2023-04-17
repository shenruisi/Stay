//
//  DownloadFileTableViewCell.h
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import <UIKit/UIKit.h>
#import "FCShared.h"
#import "FCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadFileTableViewCell<ElementType> : FCTableViewCell<ElementType>

@property(nonatomic, strong) FCTab *fctab;

@property(nonatomic, strong) UIViewController *cer;

@end

NS_ASSUME_NONNULL_END
