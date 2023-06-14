//
//  CommitCodeSucceedModalViewController.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "CommitCodeSucceedModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "UIColor+Convert.h"
#import "FCButton.h"

@interface _PointCardView : UIView

@property (nonatomic, assign) NSInteger pointValue;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *pointValueLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@end

@implementation _PointCardView

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.popup];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1;
        self.layer.borderColor = FCStyle.accent.CGColor;
        
        [self logoImageView];
        [self pointValueLabel];
        [self dateLabel];
    }
    
    return self;
}

- (UIImageView *)logoImageView{
    if (nil == _logoImageView){
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_logoImageView setImage:[UIImage imageNamed:@"NavIcon"]];
        [self addSubview:_logoImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_logoImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
            [_logoImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:15],
            [_logoImageView.widthAnchor constraintEqualToConstant:18],
            [_logoImageView.heightAnchor constraintEqualToConstant:18]
        ]];
    }
    
    return _logoImageView;
}

- (UILabel *)pointValueLabel{
    if (nil == _pointValueLabel){
        _pointValueLabel = [[UILabel alloc] init];
        _pointValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pointValueLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_pointValueLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_pointValueLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
        ]];
    }
    
    return _pointValueLabel;
}


- (UILabel *)dateLabel{
    if (nil == _dateLabel){
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = FCStyle.footnoteBold;
        _dateLabel.textColor = FCStyle.accent;
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.M.d"];
        NSString *formattedDate = [formatter stringFromDate:now];
        _dateLabel.text = formattedDate;
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_dateLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_dateLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15],
            [_dateLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-15]
        ]];
    }
    
    return _dateLabel;
}

- (void)setPointValue:(NSInteger)pointValue{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",pointValue] attributes:@{
        NSFontAttributeName : FCStyle.LargeTitle1Bold,
        NSForegroundColorAttributeName: FCStyle.accent
    }];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Points", @"") attributes:@{
        NSFontAttributeName : FCStyle.LargeTitle3Bold,
        NSForegroundColorAttributeName : FCStyle.accent
    }]];
    self.pointValueLabel.attributedText = attributedString;
}


@end

@interface CommitCodeSucceedModalViewController()

@property (nonatomic, strong) _PointCardView *pointCardView;
@property (nonatomic, strong) FCButton *confirmButton;
@end

@implementation CommitCodeSucceedModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.hideNavigationBar = YES;
    
    [self pointCardView];
    [self confirmButton];
}


- (_PointCardView *)pointCardView{
    if (nil == _pointCardView){
        _pointCardView = [[_PointCardView alloc] init];
        _pointCardView.pointValue = self.pointValue;
        _pointCardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_pointCardView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_pointCardView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_pointCardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_pointCardView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
            [_pointCardView.heightAnchor constraintEqualToConstant:200]
        ]];
    }
    
    return _pointCardView;
}

- (FCButton *)confirmButton{
    if (nil == _confirmButton){
        _confirmButton = [[FCButton alloc] init];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_confirmButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"ok", @"") attributes:@{
            NSFontAttributeName : FCStyle.bodyBold,
            NSForegroundColorAttributeName : FCStyle.accent
        }] forState:UIControlStateNormal];
        
        _confirmButton.backgroundColor = UIColor.clearColor;
        _confirmButton.layer.borderColor = FCStyle.accent.CGColor;
        _confirmButton.layer.borderWidth = 1;
        _confirmButton.layer.cornerRadius = 10;
        _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_confirmButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_confirmButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_confirmButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_confirmButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_confirmButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _confirmButton;
}

- (void)confirmAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 400);
}

@end
