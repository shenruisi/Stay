//
//  SYParseDownloadModalViewController.h
//  Stay
//
//  Created by Jin on 2023/2/10.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYParseDownloadModalViewController : ModalViewController
@property(nonatomic,strong) UINavigationController *nav;

- (void)setData:(NSArray<NSDictionary *> *)data withQualityLabe:(nullable NSString *)qualityLabell;
@end

NS_ASSUME_NONNULL_END
