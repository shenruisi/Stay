//
//  SYWebsiteViewController.m
//  Stay
//
//  Created by zly on 2022/11/21.
//

#import "SYWebsiteViewController.h"
#import "FCStyle.h"

@interface SYWebsiteViewController ()
@property (nonatomic, strong) UIScrollView *matchScrollView;
@property (nonatomic, strong) UIScrollView *grantScrollView;
@property (nonatomic, strong) UIScrollView *disableScrollView;


@end

@implementation SYWebsiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.popup;

    if ([self.type isEqualToString:@"grants"]) {
        [self.view addSubview:self.grantScrollView];
    } else if([self.type isEqualToString:@"disabledWebsites"]) {
        [self.view addSubview:self.disableScrollView];
    } else {
        [self.view addSubview:self.matchScrollView];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
 

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UILabel *)createDefaultLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = FCStyle.headline;
    label.text = text;
    [label sizeToFit];
    return  label;
}

- (UIView *)baseNote:(NSString *)title{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 24, 48)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width  - 24 - 23, 18)];
    label.font = FCStyle.footnote;
    label.text = title;
    label.textColor = FCStyle.fcBlack;
    label.left = 23;
    label.centerY = 24;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    view.backgroundColor = FCStyle.secondaryPopup;
    return view;
}

- (UIScrollView *)matchScrollView {
    if(_matchScrollView == nil) {
        CGFloat baseLeft = 12;
        _matchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        CGFloat top = 13;
        NSArray *matches = self.scriptDic[@"matches"];
        if (matches.count > 0) {
            UILabel *matchLabel = [self createDefaultLabelWithText:@"MATCHES"];
            matchLabel.top = 13;
            matchLabel.left = baseLeft;
            matchLabel.textColor = FCStyle.fcSecondaryBlack;
            matchLabel.font = FCStyle.footnoteBold;
            top = matchLabel.bottom + 8;
            [_matchScrollView addSubview:matchLabel];
            for (int i = 0; i < matches.count; i++) {
                NSString *title  = matches[i];
                UIView *view = [self baseNote:title];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i != matches.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                } else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                if (matches.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        NSArray *includes = self.scriptDic[@"includes"];

        if (includes.count > 0) {
            if(top >13) {
              top += 35;
            }            UILabel *includesLabel = [self createDefaultLabelWithText:@"INCLUDES"];
            includesLabel.top = top;
            includesLabel.left = baseLeft;
            includesLabel.textColor = FCStyle.fcSecondaryBlack;
            includesLabel.font = FCStyle.footnoteBold;
            [_matchScrollView addSubview:includesLabel];
            top = includesLabel.bottom + 8;
            
            for (int i = 0; i < includes.count; i++) {
                NSString *title  = includes[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != includes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (includes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        
        NSArray *excludes = self.scriptDic[@"excludes"];


        if (excludes.count > 0) {
            if(top >13) {
              top += 35;
            }
            UILabel *excludesLabel =  [self createDefaultLabelWithText:@"EXCLUDES"];
            excludesLabel.top = top;
            excludesLabel.left = baseLeft;
            excludesLabel.textColor = FCStyle.fcSecondaryBlack;
            excludesLabel.font = FCStyle.footnoteBold;
            [_matchScrollView addSubview:excludesLabel];
            
            top = excludesLabel.bottom + 8;
            for (int i = 0; i < excludes.count; i ++) {
                NSString *title  = excludes[i];

                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != excludes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (excludes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }

                top += 48;
            }
        }
        
        _matchScrollView.contentSize = CGSizeMake(self.view.width,top);
        
        
    }
    return _matchScrollView;
}


- (UIScrollView *)grantScrollView {
    if(_grantScrollView == nil) {
        _grantScrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        CGFloat baseLeft = 12;
        CGFloat top = 22;
        NSArray *grants = self.scriptDic[@"grants"];

        if (grants.count > 0) {
            for (int i = 0; i < grants.count; i++) {
                NSString *title  = grants[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_grantScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != grants.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_grantScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (grants.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }

                top += 48;
            }
        }
        _grantScrollView.contentSize = CGSizeMake(self.view.width,top);
    }
    return _grantScrollView;
}

- (UIScrollView *)disableScrollView {
    if(_disableScrollView == nil) {
        _disableScrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        CGFloat baseLeft = 12;
        CGFloat top = 22;
        NSArray *grants = self.scriptDic[@"disabledWebsites"];

        if (grants.count > 0) {
            for (int i = 0; i < grants.count; i++) {
                NSString *title  = grants[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_disableScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != grants.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_disableScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (grants.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }

                top += 48;
            }
        }
        _disableScrollView.contentSize = CGSizeMake(self.view.width,top);
    }
    return _disableScrollView;
}

@end
