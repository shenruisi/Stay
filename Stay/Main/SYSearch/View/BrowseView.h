//
//  BrowseView.h
//  Stay
//
//  Created by zly on 2022/5/10.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@interface BrowseView : UIView
{
    NSString *downloadUrl;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UINavigationController *navigationController;



- (void)loadView:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
