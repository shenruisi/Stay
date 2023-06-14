//
//  CommitCodeModalViewController.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "CommitCodeModalViewController.h"
#import "FCApp.h"
#import "FCLinkButton.h"
#import "FCStyle.h"
#import "FCButton.h"
#import "CommitCodeSucceedModalViewController.h"
#import "FCShared.h"
#import "API.h"
#import "FCStore.h"
#import "DeviceHelper.h"
#import "AlertHelper.h"

@protocol _CommitCodeTextFieldDelegate;
@interface _CommitCodeTextField : UITextField

@property (nonatomic, weak) id<_CommitCodeTextFieldDelegate> ccDelegate;
@end

@protocol _CommitCodeTextFieldDelegate <NSObject>

- (void)deleteOnEmpty:(_CommitCodeTextField *)textField;
@end

@implementation _CommitCodeTextField

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = FCStyle.secondaryPopup;
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1;
        self.layer.borderColor = FCStyle.fcSeparator.CGColor;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
    }
    
    return self;
}

- (void)deleteBackward{
    if (self.text.length == 0){
        if ([self.ccDelegate respondsToSelector:@selector(deleteOnEmpty:)]){
            [self.ccDelegate deleteOnEmpty:self];
        }
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
//    if ([NSStringFromSelector(action) isEqualToString:@"select:"]
//        ||[NSStringFromSelector(action) isEqualToString:@"selectAll:"]
//        ||[NSStringFromSelector(action) isEqualToString:@"copy:"]
//        ||[NSStringFromSelector(action) isEqualToString:@"cut:"]
//        ||[NSStringFromSelector(action) isEqualToString:@"_share:"]){
//        return NO;
//    }
//    return [super canPerformAction:action withSender:sender];
}

- (BOOL)becomeFirstResponder{
    self.layer.borderWidth = 2;
    self.layer.borderColor = FCStyle.accent.CGColor;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder{
    self.layer.borderWidth = 1;
    self.layer.borderColor = FCStyle.fcSeparator.CGColor;
    return [super resignFirstResponder];
}

//- (CGRect)caretRectForPosition:(UITextPosition *)position{
//    CGRect caretRect = [super caretRectForPosition:position];
//    return CGRectMake((self.width-caretRect.size.width)/2, caretRect.origin.y, caretRect.size.width, caretRect.size.height);
//}
@end

@interface CommitCodeModalViewController()<
 UITextFieldDelegate,
 _CommitCodeTextFieldDelegate
>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FCLinkButton *linkButton;
@property (nonatomic, strong) NSMutableArray<_CommitCodeTextField *> *textFieldGroup;
@property (nonatomic, strong) UIButton *pasteButton;
@property (nonatomic, strong) FCButton *confirmButton;
@property (nonatomic, strong) FCButton *dismissButton;
@end

@implementation CommitCodeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"EnterCode", @"");
    [self imageView];
    [self linkButton];
    [self textFieldGroup];
    [self pasteButton];
    
    [self dismissButton];
    [self confirmButton];
}

- (UIImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_imageView setImage:[UIImage imageNamed:@"InviteBigIcon"]];
        [self.view addSubview:_imageView];
        [NSLayoutConstraint activateConstraints:@[
            [_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:35],
            [_imageView.widthAnchor constraintEqualToConstant:100],
            [_imageView.heightAnchor constraintEqualToConstant:100]
        ]];
    }
    
    return _imageView;
}

- (FCLinkButton *)linkButton{
    if (nil == _linkButton){
        _linkButton = [[FCLinkButton alloc] init];
        _linkButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PointsUsedFor", @"") attributes:@{
            NSFontAttributeName : FCStyle.body,
            NSForegroundColorAttributeName : FCStyle.accent
        }];
        _linkButton.attributedTitle = title;
        
        [self.view addSubview:_linkButton];
        [NSLayoutConstraint activateConstraints:@[
            [_linkButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_linkButton.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:15]
        ]];
    }
    
    return _linkButton;
}

- (NSMutableArray<_CommitCodeTextField *> *)textFieldGroup{
    if (nil == _textFieldGroup){
        _textFieldGroup = [[NSMutableArray alloc] init];
        CGFloat leadingConstant = (self.view.width - 45 * 6) / 7;
        for (int i = 0; i < 6; i++){
            _CommitCodeTextField *textField = [[_CommitCodeTextField alloc] init];
            textField.delegate = self;
            textField.ccDelegate = self;
            textField.font = FCStyle.title1Bold;
            textField.textColor = FCStyle.fcBlack;
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:textField];
            [NSLayoutConstraint activateConstraints:@[
                [textField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:leadingConstant + (leadingConstant + 45) * i],
                [textField.topAnchor constraintEqualToAnchor:self.linkButton.bottomAnchor constant:20],
                [textField.widthAnchor constraintEqualToConstant:45],
                [textField.heightAnchor constraintEqualToConstant:60]
            ]];
            
            [_textFieldGroup addObject:textField];
        }
    }
    
    return _textFieldGroup;
}

- (UIButton *)pasteButton{
    if (nil == _pasteButton){
        _pasteButton = [[UIButton alloc] init];
        [_pasteButton addTarget:self action:@selector(pasteAction:) forControlEvents:UIControlEventTouchUpInside];
        _pasteButton.layer.cornerRadius = 10;
        _pasteButton.layer.borderWidth = 1;
        _pasteButton.layer.borderColor = FCStyle.accent.CGColor;
        _pasteButton.backgroundColor = UIColor.clearColor;
        _pasteButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PasteFromClipboard", @"") attributes:@{
            NSFontAttributeName : FCStyle.footnoteBold,
            NSForegroundColorAttributeName : FCStyle.accent
        }];
        
        CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, FCStyle.footnoteBold.pointSize) options:0 context:nil];
        [_pasteButton setAttributedTitle:title forState:UIControlStateNormal];
        [self.view addSubview:_pasteButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_pasteButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_pasteButton.topAnchor constraintEqualToAnchor:self.textFieldGroup[0].bottomAnchor constant:20],
            [_pasteButton.widthAnchor constraintEqualToConstant:rect.size.width + 20]
        ]];
    }
    
    return _pasteButton;
}

- (void)pasteAction:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string.length == 6){
        for (int i = 0; i < 6; i++){
            self.textFieldGroup[i].text = [[pasteboard.string substringWithRange:NSMakeRange(i, 1)] uppercaseString];
            [self updateConfirmStatus];
        }
    }
    else{
        UIImage *image =  [UIImage systemImageNamed:@"x.circle.fill"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
        image = [image imageWithTintColor:UIColor.redColor
                            renderingMode:UIImageRenderingModeAlwaysOriginal];
        [FCShared.toastCenter show:image
                         mainTitle:NSLocalizedString(@"Clipboard", @"")
                    secondaryTitle:NSLocalizedString(@"CommitCodePasteAlert", @"")];
        
    }
}

- (FCButton *)confirmButton{
    if (nil == _confirmButton){
        _confirmButton = [[FCButton alloc] init];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_confirmButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"GetPoints", @"") attributes:@{
            NSFontAttributeName : FCStyle.bodyBold,
            NSForegroundColorAttributeName : FCStyle.fcSeparator
        }] forState:UIControlStateNormal];
        
        _confirmButton.backgroundColor = UIColor.clearColor;
        _confirmButton.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _confirmButton.layer.borderWidth = 1;
        _confirmButton.layer.cornerRadius = 10;
        _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_confirmButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_confirmButton.bottomAnchor constraintEqualToAnchor:self.dismissButton.topAnchor constant:-15],
            [_confirmButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_confirmButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_confirmButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _confirmButton;
}

- (void)updateConfirmStatus{
    BOOL active = YES;
    for (int i = 0; i < self.textFieldGroup.count; i++){
        _CommitCodeTextField *textField = self.textFieldGroup[i];
        active &= textField.text.length > 0;
    }
    
    [self.confirmButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"GetPoints", @"") attributes:@{
        NSFontAttributeName : FCStyle.bodyBold,
        NSForegroundColorAttributeName : active ? FCStyle.accent : FCStyle.fcSeparator
    }] forState:UIControlStateNormal];
    
    self.confirmButton.layer.borderColor = active ? FCStyle.accent.CGColor : FCStyle.fcSeparator.CGColor;
}

- (void)confirmAction:(id)sender{
    NSMutableString *code = [[NSMutableString alloc] init];
    for (int i = 0; i < self.textFieldGroup.count; i++){
        [code appendString:self.textFieldGroup[i].text];
    }
    
    FCButton *button = (FCButton *)sender;
    [self.navigationController.slideController startLoading];
    [button startLoading];
    [[API shared] queryPath:@"/code/commit"
                        pro:[[FCStore shared] getPlan:NO] != FCPlan.None
                   deviceId:DeviceHelper.uuid
                        biz:@{
        @"code": code
    } completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
        [self.navigationController.slideController stopLoading];
        [button stopLoading];
        if (statusCode == 200){
            CommitCodeSucceedModalViewController *cer = [[CommitCodeSucceedModalViewController alloc] init];
            cer.pointValue = 20;
            [self.navigationController pushModalViewController:cer];
        }
        else{
            if (statusCode == 404 || statusCode == 409){
                [AlertHelper simpleWithTitle:NSLocalizedString(@"Error", @"")
                                     message:NSLocalizedString(server[@"message"] ? server[@"message"] : @"CodeNotFound", @"")
                                       inCer:self.navigationController.slideController.baseCer];
            }
            else{
                [AlertHelper simpleWithTitle:NSLocalizedString(@"Error", @"")
                                     message:[error localizedDescription]
                                       inCer:self.navigationController.slideController.baseCer];
            }
        }
    }];
}

- (FCButton *)dismissButton{
    if (nil == _dismissButton){
        _dismissButton = [[FCButton alloc] init];
        [_dismissButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"NoCodeSkip", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcSecondaryBlack,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _dismissButton.backgroundColor = FCStyle.popup;
        _dismissButton.layer.borderColor = FCStyle.borderColor.CGColor;
        _dismissButton.layer.borderWidth = 1;
        _dismissButton.layer.cornerRadius = 10;
        _dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_dismissButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_dismissButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_dismissButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_dismissButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_dismissButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _dismissButton;
}

- (void)dismissAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (void)nextResponse:(_CommitCodeTextField *)textField{
    [textField resignFirstResponder];
    NSUInteger index = [self.textFieldGroup indexOfObject:textField];
    if (index < self.textFieldGroup.count - 1){
        [[self.textFieldGroup objectAtIndex:index + 1] becomeFirstResponder];
    }
}

- (void)prevResponse:(_CommitCodeTextField *)textField{
    [textField resignFirstResponder];
    NSUInteger index = [self.textFieldGroup indexOfObject:textField];
    if (index > 0){
        [[self.textFieldGroup objectAtIndex:index - 1] becomeFirstResponder];
    }
}

- (BOOL)textField:(_CommitCodeTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *allowedCharacters = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet *inputCharacters = [NSCharacterSet characterSetWithCharactersInString:string];
    BOOL isAllowed = [allowedCharacters isSupersetOfSet:inputCharacters];
    if (!isAllowed) {
        return NO;
    }

    NSString *uppercaseString = [string uppercaseString];

    textField.text = uppercaseString;

    if (textField.text.length > 0){
        [self nextResponse:textField];
    }
    [self updateConfirmStatus];
    return NO;
}

- (void)deleteOnEmpty:(_CommitCodeTextField *)textField{
    [self prevResponse:textField];
}

- (void)textFieldDidChangeSelection:(UITextField *)textField{
    UITextPosition *position = [textField positionFromPosition:textField.beginningOfDocument offset:textField.text.length];
    textField.selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 500);
}
@end
