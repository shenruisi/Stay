//
//  FCTableViewHeadCell.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "FCTableViewHeadCell.h"
#import "FCTableViewCell.h"
#import "FCStyle.h"
#import "FCTapView.h"

@implementation FCTableViewHeadMenuItem

@end

@interface FCTableViewHeadCell()

@property (nonatomic, strong) FCView *menuView;
@end

@implementation FCTableViewHeadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self menuView];
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setMenus:(NSArray<FCTableViewHeadMenuItem *> *)menus{
    for (UIView *view in self.menuView.subviews){
        [view removeFromSuperview];
    }
    
    _menus = menus;
    CGFloat left = 0;
    for (FCTableViewHeadMenuItem *item in _menus){
        CGRect rect = [item.title boundingRectWithSize:CGSizeMake(MAXFLOAT, FCStyle.subHeadlineBold.pointSize) options:0 attributes:@{
            NSFontAttributeName : FCStyle.subHeadlineBold
        } context:nil];
        
        CGFloat width = rect.size.width + 22 + 25;
        FCTapView *view = [[FCTapView alloc] initWithFrame:CGRectMake(left, 0, width, 35)];
        view.backgroundColor = UIColor.clearColor;
        view.layer.borderColor = FCStyle.fcSeparator.CGColor;
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = 10;
        view.action = item.action;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 22, 22)];
        imageView.centerY = view.centerY;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:item.image];
        [view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 5, 0, rect.size.width, 22)];
        label.backgroundColor = UIColor.clearColor;
        label.text = item.title;
        label.centerY = view.centerY;
        label.font = FCStyle.subHeadlineBold;
        label.textColor = FCStyle.fcSecondaryBlack;
        [view addSubview:label];
        
        [self.menuView addSubview:view];
        
        left += 10 + width;
    }
}

- (FCView *)menuView{
    if (nil == _menuView){
        _menuView = [[FCView alloc] init];
        _menuView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_menuView];
        [NSLayoutConstraint activateConstraints:@[
            [_menuView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:[FCTableViewCell contentInset].left],
            [_menuView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-[FCTableViewCell contentInset].right],
            [_menuView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[FCTableViewCell contentInset].top],
            [_menuView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:[FCTableViewCell contentInset].bottom]
        ]];
    }
    
    return _menuView;
}


@end
