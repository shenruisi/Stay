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

@interface AdBlockDetailViewController ()

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) ContentFilterEditorView *editorView;
@end

@implementation AdBlockDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    self.title = self.contentFilter.title;
    [self editorView];
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.editorView setStrings:[self.contentFilter fetchRules]];
//}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.editorView setStrings:[self.contentFilter fetchRules]];
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

- (ContentFilterEditorView *)editorView{
    if (nil == _editorView){
        _editorView = [[ContentFilterEditorView alloc] init];
        _editorView.translatesAutoresizingMaskIntoConstraints = NO;
        _editorView.backgroundColor = FCStyle.secondaryBackground;
        _editorView.layer.cornerRadius = 10;
        _editorView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _editorView.clipsToBounds = YES;
        [self.view addSubview:_editorView];
        [NSLayoutConstraint activateConstraints:@[
            [_editorView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_editorView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_editorView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.navigationController.navigationBar.frame.size.height],
            [_editorView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
        
    }
    
    return _editorView;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
