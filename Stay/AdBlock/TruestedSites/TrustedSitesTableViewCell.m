//
//  TrustedSitesTableViewCell.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "TrustedSitesTableViewCell.h"
#import "TruestedSite.h"
#import "FCStyle.h"

@interface TrustedSitesTableViewCell()

@property (nonatomic, strong) UILabel *domainLabel;
@end

@implementation TrustedSitesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self domainLabel];
    }
    
    return self;
}


- (void)buildWithElement:(TruestedSite *)element{
    self.domainLabel.text = element.domain;
}

- (UILabel *)domainLabel{
    if (nil == _domainLabel){
        _domainLabel = [[UILabel alloc] init];
        _domainLabel.textColor = FCStyle.fcBlack;
        _domainLabel.backgroundColor = UIColor.clearColor;
        _domainLabel.font = FCStyle.body;
        _domainLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_domainLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_domainLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_domainLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10],
            [_domainLabel.centerYAnchor constraintEqualToAnchor:self.fcContentView.centerYAnchor]
        ]];
    }
    
    return _domainLabel;
}

+ (NSString *)identifier{
    return @"TrustedSitesTableViewCell";
}


@end
