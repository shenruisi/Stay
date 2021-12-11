//
//  JSDetailCell.m
//  Stay
//
//  Created by zly on 2021/11/10.
//

#import "JSDetailCell.h"

@implementation JSDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
//        [self.contentView addSubview:self.authorLabel];
//        [self.contentView addSubview:self.descLabel];
    

       
        
    }
    return self;
}

- (UILabel *)titleLabel {
    if (_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, kScreenWidth, 21)];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _titleLabel;
}

@end
