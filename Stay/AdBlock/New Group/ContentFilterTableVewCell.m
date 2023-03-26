//
//  ContentFilterTableVewCell.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "ContentFilterTableVewCell.h"
#import "FCStyle.h"
#import "ContentFilter.h"
#import "StateView.h"
#import "UIView+Duplicate.h"

@interface ContentFilterTableVewCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) StateView *stateView;
@end

@implementation ContentFilterTableVewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self nameLabel];
        [self stateView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tap{
    [super tap];
    
    UIView *containerView = [self.fcContentView.containerView duplicate];
    [self.contentView addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:[FCTableViewCell contentInset].left],
        [containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-[FCTableViewCell contentInset].right],
        [containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[FCTableViewCell contentInset].top],
        [containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[FCTableViewCell contentInset].bottom]
    ]];
    
    UILabel *nameLabel = (UILabel *)[self.nameLabel duplicate];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:nameLabel];
    [NSLayoutConstraint activateConstraints:@[
        [nameLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
        [nameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10]
    ]];
    
    StateView *stateView = (StateView *)[self.stateView fcDuplicate];
    stateView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:stateView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stateView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
        [stateView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-15]
    ]];
    
//    self.contentView.maskView = [[UIView alloc] init];
    
    
}

- (void)buildWithElement:(ContentFilter *)element{
    self.nameLabel.text = element.name;
    self.stateView.active = element.active;
}

- (UILabel *)nameLabel{
    if (nil == _nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = FCStyle.body;
        _nameLabel.textColor = FCStyle.fcBlack;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_nameLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_nameLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:10]
        ]];
    }
    
    return _nameLabel;
}

- (StateView *)stateView{
    if (nil == _stateView){
        _stateView = [[StateView alloc] init];
        _stateView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_stateView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_stateView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_stateView.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-15]
        ]];
    }
    
    return _stateView;
}

+ (NSString *)identifier{
    return @"ContentFilterTableVewCell";
}

@end
