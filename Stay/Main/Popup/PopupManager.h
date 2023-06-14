//
//  PopupManager.h
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull PopupShouldShowCodeCommitNotification;

@interface PopupManager : NSObject

+ (instancetype)shared;

@property (nonatomic, assign) BOOL ingorePopup;
@end

NS_ASSUME_NONNULL_END
