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
#import "ContentFilterManager.h"
#import "FCShared.h"
#import "DeviceHelper.h"

@interface AdBlockDetailViewController ()

@property (nonatomic, strong) UIBarButtonItem *moreItem;
@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (nonatomic, strong) ContentFilterEditorView *editorView;
@property (nonatomic, strong) ContentFilterEditSlideController *editSlideController;
@end

@implementation AdBlockDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    if (ContentFilterTypeCustom == self.contentFilter.type
        ||ContentFilterTypeTag == self.contentFilter.type){
        if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
             self.rightBarButtonItems = @[self.saveItem];
        }
        else{
            self.navigationItem.rightBarButtonItems = @[self.saveItem];
        }
    }
    else{
        if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
            self.rightBarButtonItems = @[self.moreItem];
        }
        else{
            self.navigationItem.rightBarButtonItems = @[self.moreItem];
        }
    }
    self.title = self.contentFilter.title;
    [self editorView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentFilterDidUpdateHandler:) name:ContentFilterDidUpdateNotification object:nil];
}

- (void)contentFilterDidUpdateHandler:(NSNotification *)note{
    self.title = self.contentFilter.title;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (ContentFilterTypeCustom == self.contentFilter.type
        ||ContentFilterTypeTag == self.contentFilter.type){
        self.editorView.editable = YES;
    }
    else{
        self.editorView.editable = NO;
    }
    [self.editorView setStrings:[self.contentFilter fetchRules:nil]];
}

- (void)refreshRules{
    if (![[NSThread currentThread] isMainThread]){
        [self performSelectorOnMainThread:@selector(refreshRules) withObject:nil waitUntilDone:YES];
        return;
    }
    [self.editorView setStrings:[self.contentFilter fetchRules:nil]];
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

- (UIBarButtonItem *)saveItem{
    if (nil == _saveItem){
        _saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"")
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(saveAction:)];
        _saveItem.tintColor = FCStyle.accent;
    }
    
    return _saveItem;
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

- (void)saveAction:(id)sender{
    NSString *strings = self.editorView.strings;
    NSError *error;
    [[ContentFilterManager shared] writeTextToFileName:self.contentFilter.path content:strings error:&error];
    if (error){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AdBlock", @"")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        __weak AdBlockDetailViewController *weakSelf = self;
        [self.contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AdBlock", @"")
                                                                                   message:[error localizedDescription]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alert addAction:confirm];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else{
                    UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
                    image = [image imageWithTintColor:FCStyle.fcBlack
                                        renderingMode:UIImageRenderingModeAlwaysOriginal];
                    [FCShared.toastCenter show:image
                                     mainTitle:weakSelf.contentFilter.title
                                secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
                }
            });
        }];
    }
}

- (void)clear{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ContentFilterDidUpdateNotification
                                                  object:nil];
}

@end
