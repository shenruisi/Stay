//
//  DisabledWebsites.h
//  Stay
//
//  Created by ris on 2022/12/19.
//

#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisabledWebsites : FCDisk
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray *> *contentDic;
@end

NS_ASSUME_NONNULL_END
