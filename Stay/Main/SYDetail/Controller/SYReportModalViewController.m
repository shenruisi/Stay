//
//  SYReportModalViewController.m
//  Stay
//
//  Created by zly on 2023/2/8.
//

#import "SYReportModalViewController.h"
#import "FCStyle.h"
#import "FCApp.h"
#import "ImageHelper.h"
#import "UIColor+Convert.h"
#import "ModalItemElement.h"
#import "UIView+Layout.h"

@interface SYReportModalViewController()
@property (nonatomic, strong) UITextView *others;
@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation SYReportModalViewController

- (void)viewDidLoad {
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = NO;
    self.title = NSLocalizedString(@"Report a problem", @"");
    
    CGFloat left = 14;
    CGFloat top = 0;
    
    UILabel *platformLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    platformLabel.font = FCStyle.bodyBold;
    platformLabel.textColor = FCStyle.fcSecondaryBlack;
    platformLabel.textAlignment = NSTextAlignmentLeft;
    platformLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    platformLabel.text =NSLocalizedString(@"Type", @"");
    platformLabel.top = top;
    [self.view addSubview:platformLabel];
    
    NSArray *array = @[@"Userscript not working",@"Violation of user pricacy",@"Do not know how to use"];
    CGFloat btnleft = 14;
    CGFloat btnTop = platformLabel.bottom + 12;
    for(int i = 0; i < 3;i++) {
        UIButton *btn = [self createBtn:array[i] tag:i];
        btn.left = btnleft;
        btn.top = btnTop;
  
        [self.view addSubview:btn];
        btnleft = btn.right + 20;
        top = btn.bottom + 10;
        if(i == 2) {
            btn.top = top;
            btn.left = left;
            top = btn.bottom + 13;
        }
        
    }
    
    UILabel *otherLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    otherLabel.font = FCStyle.bodyBold;
    otherLabel.textColor = FCStyle.fcSecondaryBlack;
    otherLabel.textAlignment = NSTextAlignmentLeft;
    otherLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    otherLabel.text =NSLocalizedString(@"Others", @"");
    otherLabel.top = top;
    [self.view addSubview:otherLabel];
    
    self.others.top = otherLabel.bottom + 13;
    self.others.left = left;
    [self.view addSubview:self.others];
    
    
    self.submitButton.top = self.others.bottom + 25;
    self.submitButton.left = left;
    [self.view addSubview:self.submitButton];

}


- (UIButton * )createBtn:(NSString *)title tag:(int)tag {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 25)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:FCStyle.grayNoteColor forState:UIControlStateNormal];
    btn.titleLabel.font = FCStyle.footnote;
    btn.backgroundColor = FCStyle.background;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = FCStyle.borderColor.CGColor;
    btn.layer.cornerRadius = 8;
    btn.tag = tag;
    [btn addTarget:self action:@selector(changeBtnStatus:) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    btn.width += 10;
    return btn;
}

- (void)changeBtnStatus:(UIButton *)btn {
    
    btn.selected = !btn.selected;

    if(btn.selected) {
        btn.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
    
        [self.errors addObject:btn.titleLabel.text];
    } else {
        btn.backgroundColor = FCStyle.background;
        [self.errors removeObject:btn.titleLabel.text];
    }
}

- (void)reportError {
    NSString *url = [NSString stringWithFormat:@"mailto:feedback@fastclip.app?subject=Feedback-%@",NSLocalizedString(@"FeedbackEnabling", @"")];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                       options:@{} completionHandler:^(BOOL succeed){}];
}

- (UITextView *)others {
    if(nil == _others) {
        _others= [[UITextView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 30, 93)];
        _others.font = FCStyle.body;
        _others.backgroundColor = FCStyle.background;
        _others.layer.cornerRadius = 10;
        _others.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _others;
}

- (UIButton *)submitButton{
    if (nil == _submitButton){
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_submitButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Report", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_submitButton addTarget:self
                                 action:@selector(reportError)
                       forControlEvents:UIControlEventTouchUpInside];
        _submitButton.backgroundColor = FCStyle.accent;
        _submitButton.layer.cornerRadius = 10;
        _submitButton.layer.masksToBounds = YES;
        [self.view addSubview:_submitButton];
    }
    
    return _submitButton;
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 380);
}


@end
