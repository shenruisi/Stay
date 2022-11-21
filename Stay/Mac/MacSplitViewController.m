//
//  MacSplitViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/10/9.
//

#import "MacSplitViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"

static CGFloat MIN_PRIMARY_WIDTH = 310;
static CGFloat MAX_PRIMARY_WIDTH = 540;

@interface MacSplitViewController ()


@end

@implementation MacSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self placeHolderTitleView];
    self.view.backgroundColor = FCStyle.fcSeparator;
    self.minimumPrimaryColumnWidth = MIN_PRIMARY_WIDTH;
    self.maximumPrimaryColumnWidth = MAX_PRIMARY_WIDTH;
    NSInteger preferredWidth = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyMacPrimaryWidth];
    if (preferredWidth > 0){
        self.preferredPrimaryColumnWidth = preferredWidth;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sceneWillEnterForeground:)
                                                 name:UISceneWillEnterForegroundNotification
                                               object:nil];
}

- (void)sceneWillEnterForeground:(NSNotification *)note{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.stay.notification.SVCDidBecomeActiveNotification"
                                                        object:nil];
}

- (id)toolbar{
    return nil;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self layout];
}

- (UILabel *)placeHolderTitleView{
    if (nil == _placeHolderTitleView){
        _placeHolderTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
        _placeHolderTitleView.backgroundColor = UIColor.secondarySystemBackgroundColor;
        _placeHolderTitleView.layer.zPosition = MAXFLOAT;
        _placeHolderTitleView.text = @"Stay for Mac";
        _placeHolderTitleView.textAlignment = NSTextAlignmentCenter;
        _placeHolderTitleView.font = FCStyle.subHeadlineBold;
        _placeHolderTitleView.textColor = FCStyle.fcThirdBlack;
        [self.view addSubview:_placeHolderTitleView];
    }
    
    return _placeHolderTitleView;
}

- (void)layout{
    [self.placeHolderTitleView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UISceneWillEnterForegroundNotification
                                                  object:nil];
}

@end
