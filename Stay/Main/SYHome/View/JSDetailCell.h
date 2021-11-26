//
//  JSDetailCell.h
//  Stay
//
//  Created by zly on 2021/11/10.
//

#import <UIKit/UIKit.h>
//#import "ScriptDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSDetailCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *descLabel;


//- (void)loadDetail:(ScriptDetailModel *)jsDetail;


@end

NS_ASSUME_NONNULL_END
