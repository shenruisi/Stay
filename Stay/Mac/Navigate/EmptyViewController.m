//
//  EmptyViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "EmptyViewController.h"
#import "FCStyle.h"

@interface EmptyViewController ()

@property (nonatomic, strong) UILabel *label;
@end

@implementation EmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self label];
    NSLog(@"EmptyViewController view %@",self.view);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, (kScreenHeight - 18)/2, self.view.frame.size.width, 18)];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appname = infoDictionary[@"CFBundleDisplayName"];
        NSString *appVersion = [NSString stringWithFormat:@" %@(%@)",infoDictionary[@"CFBundleShortVersionString"],infoDictionary[@"CFBundleVersion"]];
        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appname attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.headlineBold,
//            NSObliquenessAttributeName:@(10)
            
        }]];
        
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appVersion attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
//            NSObliquenessAttributeName:@(10)
            
        }]];
        
        _label.attributedText = builder;
        _label.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:_label];
    }
    
    return _label;
}

@end
