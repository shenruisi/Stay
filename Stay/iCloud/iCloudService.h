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
- (BOOL)firstInit:(NSError * __strong *)outError;
- (void)pushUserscripts:(NSArray *)userscripts
              syncStart:(void(^)(void))syncStart
      completionHandler:(void (^)(NSError *))completionHandler;
@end

NS_ASSUME_NONNULL_END
