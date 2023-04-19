//
//  AdBlockDetailViewController.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "AdBlockDetailViewController.h"
#import "FCStyle.h"
#import "ImageHelper.h"
#import "ContentFilterEditorView.h"
#import "ContentFilterEditSlideController.h"

@interface AdBlockDetailViewController ()

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *moreItem;
@property (nonatomic, strong) ContentFilterEditorView *editorView;
@property (nonatomic, strong) ContentFilterEditSlideController *editSlideController;
@end

@implementation AdBlockDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    self.navigationItem.rightBarButtonItems = @[self.moreItem];
    self.title = self.contentFilter.title;
    [self editorView];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.editorView.editable = NO;
    [self.editorView setStrings:[self.contentFilter fetchRules:nil]];
}

- (void)refreshRules{
    [self.editorView setStrings:[self.contentFilter fetchRules:nil]];
}

- (UIBarButtonItem *)backItem{
    if (nil == _backItem){
        _backItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"chevron.backward"
                                                                           font:FCStyle.headline
                                                                          color:FCStyle.accent]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(backAction:)];
    }
    
    return _backItem;
}

- (UIBarButtonItem *)moreItem{
    if (nil == _moreItem){
        _moreItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"ellipsis"
                                                                           font:FCStyle.headline
                                                                          color:FCStyle.accent]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(moreAction:)];
    }
    
    return _moreItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.editSlideController isShown]){
        [self.editSlideController dismiss];
    }
}

- (ContentFilterEditorView *)editorView{
    if (nil == _editorView){
        _editorView = [[ContentFilterEditorView alloc] init];
        _editorView.translatesAutoresizingMaskIntoConstraints = NO;
        _editorView.backgroundColor = FCStyle.secondaryBackground;
//        _editorView.layer.cornerRadius = 10;
//        _editorView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
//        _editorView.clipsToBounds = YES;
        [self.view addSubview:_editorView];
        [NSLayoutConstraint activateConstraints:@[
            [_editorView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_editorView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_editorView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_editorView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
        
    }
    
    return _editorView;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAction:(id)sender{
    if ([self.editSlideController isShown]){
        [self.editSlideController dismiss];
    }
    self.editSlideController = [[ContentFilterEditSlideController alloc] initWithContentFilter:self.contentFilter];
    self.editSlideController.baseCer = self;
    [self.editSlideController show];
}

@end
