//
//  ModalViewController.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "ModalViewController.h"
#import "FCApp.h"

@interface ModalViewController()<
 ModalNavigationBarDelegate
>{
    UIView *_view;
    ModalNavigationBar *_navigationBar;
}

@property (nonatomic, strong) UIView *mainView;
@end

@implementation ModalViewController

- (instancetype)init{
    if (self = [super init]){
        [self mainView];
        [self.mainView addSubview:[self navigationBar]];
        [self.mainView addSubview:[self view]];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title{
    self.navigationBar.title = title;
}

- (void)willSee{
    CGSize size = [self mainViewSize];
    [self.mainView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.navigationBar setFrame:CGRectMake(0, 0, size.width, self.hideNavigationBar ? 0 : self.navigationBar.frame.size.height)];
    [self.view setFrame:CGRectMake(0, self.navigationBar.frame.size.height, size.width,  size.height - self.navigationBar.frame.size.height)];
}



- (ModalNavigationBar *)navigationBar{
    if (nil == _navigationBar){
        _navigationBar = [[ModalNavigationBar alloc] init];
        _navigationBar.delegate = self;
    }
    
    return _navigationBar;
}

- (UIView *)view{
    if (nil == _view){
        _view = [[UIView alloc] init];
    }
    
    return _view;
}

- (UIView *)mainView{
    if (nil == _mainView){
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _mainView;
}

- (UIView *)getMainView{
    return self.mainView;
}

- (CGSize)mainViewSize{
    return CGSizeZero;
}

- (CGFloat)maxViewWidth{
    return MIN(FCApp.keyWindow.frame.size.width, 392);
}

- (void)navigationBarDidClickCancelButton{
    if (self.isRoot){
        [self.navigationController.slideController dismiss];
    }
    else{
        [self.navigationController popModalViewController];
    }
    
}


- (void)viewWillAppear{}
- (void)viewDidAppear{}
- (void)viewWillDisappear{}
- (void)viewDisappearIntermediate{}
- (void)viewDidDisappear{}
- (void)viewDidLoad{}
@end
