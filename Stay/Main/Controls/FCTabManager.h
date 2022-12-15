//
//  FCTabManager.h
//  FastClip-iOS
//
//  Created by ris on 2022/1/20.
//

#import <Foundation/Foundation.h>

#import "FCTab.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTabManager : NSObject{    
}

@property (readonly) NSMutableArray<FCTab *> *tabs;

- (FCTab *)newTab;
- (FCTab *)addTabWithUUID:(NSString *)uuid;
- (void)deleteTab:(FCTab *)tab;
- (void)deleteTabWithUUID:(NSString *)uuid;
- (FCTab *)tabOfUUID:(NSString *)uuid;

- (void)resetAllTabs;

- (NSString *)tabNameWithUUID:(NSString *)uuid;
- (UIImage *)tabImageWithUUID:(NSString *)uuid pointSize:(CGFloat)pointSize;

@end

NS_ASSUME_NONNULL_END
