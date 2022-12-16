//
//  ModalItemInputView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/12.
//

#import "ModalItemInputView.h"
#import "FCLayoutTextField.h"
#import "FCStyle.h"
#import "UIView+Layout.h"

@interface ModalItemInputView()<
 UITextFieldDelegate
>

@property (nonatomic, strong) FCLayoutTextField *textField;
@end

@implementation ModalItemInputView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self textField];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    element.inputEntity.textField = self.textField;
    self.textField.text = element.inputEntity.text;
}

- (FCLayoutTextField *)textField{
    if (nil == _textField){
        _textField = [[FCLayoutTextField alloc] init];
        __weak ModalItemInputView *weak = self;
        _textField.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(weak.element.spacing3,
                                        (superView.height - FCStyle.body.lineHeight)/2,
                                        superView.width - 2 * weak.element.spacing3,
                                        FCStyle.body.lineHeight)];
        };
        _textField.keyboardType = self.element.inputEntity.keyboardType;
        _textField.placeholder = self.element.inputEntity.placeholder;
        _textField.textColor = self.element.enable ? FCStyle.fcBlack : FCStyle.fcSeparator;
        _textField.backgroundColor = UIColor.clearColor;
        _textField.delegate = self;
        [self.contentView addSubview:_textField];
    }
    
    return _textField;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return self.element.enable;
}

@end
