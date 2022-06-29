//
//  iCloudService.h
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface iCloudService : NSObject

- (BOOL)logged;
- (NSString *)serviceIdentifier;
- (BOOL)firstInit:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
