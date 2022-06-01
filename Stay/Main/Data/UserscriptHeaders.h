//
//  UserscriptHeaders.h
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserscriptHeaders : FCDisk

@property (nonatomic, strong) NSArray<NSDictionary *> *content;
@end

NS_ASSUME_NONNULL_END
