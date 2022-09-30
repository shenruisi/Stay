//
//  RunsRecord.h
//  Stay
//
//  Created by ris on 2022/9/30.
//

#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface RunsRecord : FCDisk

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *contentDic;
@end

NS_ASSUME_NONNULL_END
