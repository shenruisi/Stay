//
//  SYSubmitScriptViewController.m
//  Stay
//
//  Created by zly on 2023/2/7.
//

#import "SYSubmitScriptViewController.h"
#import "FCStyle.h"
#import "FCApp.h"
#import "ImageHelper.h"
#import "UIColor+Convert.h"
#import "ModalItemElement.h"
#import "UIView+Layout.h"
#import "SYNetworkUtils.h"

@interface SYSubmitScriptViewController()
@property (nonatomic, strong) UITextView *tagElements;
@property (nonatomic, strong) UITextView *emailElements;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSMutableArray *platforms;
@end
@implementation SYSubmitScriptViewController

- (void)viewDidLoad {
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = NO;
    self.title = NSLocalizedString(@"Submit to Stay Fork", @"");
    
    
    CGFloat left = 14;
    CGFloat top = 0;
    
    UILabel *platformLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    platformLabel.font = FCStyle.bodyBold;
    platformLabel.textColor = FCStyle.fcSecondaryBlack;
    platformLabel.textAlignment = NSTextAlignmentLeft;
    platformLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    platformLabel.text =NSLocalizedString(@"Platform", @"");
    platformLabel.top = top;
    [self.view addSubview:platformLabel];
    
    NSArray *array = @[@"iPhone",@"iPad",@"Mac"];
    
    
    CGFloat btnleft = 14;
    CGFloat btnTop = platformLabel.bottom + 12;
    for(int i = 0; i < 3; i++) {
        UIButton *btn = [self createBtn:array[i] tag:i];
        btn.left = btnleft;
        btn.top = btnTop;
        [self.view addSubview:btn];
        btnleft = btn.right + 20;
        top = btn.bottom + 13;
    }
    
    UILabel *tagsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    tagsLabel.font = FCStyle.bodyBold;
    tagsLabel.textColor = FCStyle.fcSecondaryBlack;
    tagsLabel.textAlignment = NSTextAlignmentLeft;
    tagsLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    tagsLabel.text =NSLocalizedString(@"Tags", @"");
    tagsLabel.top = top;
    [self.view addSubview:tagsLabel];

    self.tagElements.top = tagsLabel.bottom + 13;
    self.tagElements.left = left;
    
    [self.view addSubview:self.tagElements];
    
    top = self.tagElements.bottom + 13;
    
    UILabel *email = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    email.font = FCStyle.bodyBold;
    email.textColor = FCStyle.fcSecondaryBlack;
    email.textAlignment = NSTextAlignmentLeft;
    email.lineBreakMode= NSLineBreakByTruncatingTail;
    email.text =NSLocalizedString(@"Email", @"");
    email.top = top;
    [self.view addSubview:email];
    
    
    self.emailElements.top = email.bottom + 13;
    self.emailElements.left = left;
    
    [self.view addSubview:self.emailElements];

    self.submitButton.left = left;
    self.submitButton.top = self.emailElements.bottom + 26;
    
    [self.view addSubview:self.submitButton];
    
    
}


- (UIButton * )createBtn:(NSString *)title tag:(int)tag {
    NSString *imageName = @"laptopcomputer";
    
    if([title isEqualToString:@"iPhone"]) {
        imageName = @"iphone";
    } else if([title isEqualToString:@"iPad"]) {
        imageName = @"ipad";
    } else if([title isEqualToString:@"Mac"]) {
        imageName = @"laptopcomputer";
    }
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 25)];
    [btn setImage:[ImageHelper sfNamed:imageName font:FCStyle.footnote color:FCStyle.grayNoteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:FCStyle.grayNoteColor forState:UIControlStateNormal];
    btn.titleLabel.font = FCStyle.footnoteBold;
    btn.backgroundColor = FCStyle.background;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = FCStyle.borderColor.CGColor;
    btn.layer.cornerRadius = 8;
    btn.tag = tag;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [btn addTarget:self action:@selector(changeBtnStatus:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)changeBtnStatus:(UIButton *)btn {
    
    NSString *type = @"iPhone";
    NSString *title = @"iphone";
    
    switch (btn.tag) {
        case 0:
            type = @"iPhone";
            title = @"iphone";
            break;
        case 1:
            type = @"iPad";
            title = @"ipad";
            break;
        case 2:
            type = @"mac";
            title = @"mac";
            break;
        default:
            break;
    }
    btn.selected = !btn.selected;

    if(btn.selected) {
        btn.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
    
        [self.platforms addObject:title];
    } else {
        btn.backgroundColor = FCStyle.background;
        [self.platforms removeObject:title];
    }
}

- (void)submitJob {
    
    if(self.platforms.count == 0) {
        UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PlatformNotEmpty", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *onlyOneConform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [onlyOneAlert addAction:onlyOneConform];
        [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];
        return;
    }
    
    if(self.emailElements.text == NULL || self.emailElements.text.length <= 0) {
        UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"EmailNotEmpty", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *onlyOneConform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [onlyOneAlert addAction:onlyOneConform];
        [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];
        return;
    }
    
    if(self.tagElements.text == NULL || self.tagElements.text.length <= 0) {
        UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TagNotEmpty", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *onlyOneConform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [onlyOneAlert addAction:onlyOneConform];
        [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];
        return;
    }
    
    
    NSArray *tags = [self.tagElements.text componentsSeparatedByString:@","];
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        [[SYNetworkUtils shareInstance] requestPOST: @"https://api.shenyin.name/stay-fork/submit?collector" params:@{@"biz":@{@"uuid":self.script.uuid,@"script_url":self.script.downloadUrl,@"platforms":self.platforms,@"mail":self.emailElements.text,@"tags":tags }} successBlock:^(NSString * _Nonnull responseObject) {
            
            UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UploadSuccess", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *onlyOneConform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
            
                [self.navigationController.slideController dismiss];
            }];
            [onlyOneAlert addAction:onlyOneConform];
            [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];
    
        } failBlock:^(NSError * _Nonnull error) {
           
        }];
    });
    
    
}


- (UITextView *)tagElements {
    if(nil == _tagElements) {
        _tagElements= [[UITextView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 30, 45)];
        _tagElements.font = FCStyle.body;
        _tagElements.backgroundColor = FCStyle.background;
        _tagElements.layer.cornerRadius = 10;
        _tagElements.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);

        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = NSLocalizedString(@"SplitBySpace", @"");
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = FCStyle.fcPlaceHolder;
        [placeHolderLabel sizeToFit];
        placeHolderLabel.font = FCStyle.body;
        [_tagElements addSubview:placeHolderLabel];
        [_tagElements setValue:placeHolderLabel forKey:@"_placeholderLabel"];

    }
    return _tagElements;
}

- (UITextView *)emailElements {
    if(nil == _emailElements) {
        _emailElements= [[UITextView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 30, 45)];
        _emailElements.font = FCStyle.body;
        _emailElements.backgroundColor = FCStyle.background;
        _emailElements.layer.cornerRadius = 10;
        _emailElements.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _emailElements;
}

- (UIButton *)submitButton{
    if (nil == _submitButton){
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_submitButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Submit", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_submitButton addTarget:self
                                 action:@selector(submitJob)
                       forControlEvents:UIControlEventTouchUpInside];
        _submitButton.backgroundColor = FCStyle.accent;
        _submitButton.layer.cornerRadius = 10;
        _submitButton.layer.masksToBounds = YES;
        [self.view addSubview:_submitButton];
    }
    
    return _submitButton;
}

- (NSMutableArray *)platforms {
    if(_platforms == nil) {
        _platforms = [NSMutableArray array];
    }
    return _platforms;
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 380);
}


@end
