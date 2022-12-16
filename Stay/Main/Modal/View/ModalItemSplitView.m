//
//  ModalItemSplitView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalItemSplitView.h"
#import "UIView+Layout.h"
#import "FCLayoutView.h"
#import "FCLayoutLabel.h"
#import "FCStyle.h"

@interface ModalItemSplitView()

@property (nonatomic, strong) FCLayoutView *lineView;
@property (nonatomic, strong) FCLayoutLabel *label1;
@property (nonatomic, strong) FCLayoutLabel *label2;
@end

@implementation ModalItemSplitView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self label1];
    [self lineView];
    [self label2];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    [self.label1 setText:element.splitEntity.text1];
    [self.label2 setText:element.splitEntity.text2];
}

- (FCLayoutLabel *)label1{
    if (nil == _label1){
        _label1 = [[FCLayoutLabel alloc] init];
        __weak ModalItemSplitView *weakSelf = self;
        _label1.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat width = [weakSelf.element.latestContentUserInfo[@"text1Width"] floatValue];
            [itself setFrame:CGRectMake((superView.width/2 - width) / 2,
                                        (superView.height - FCStyle.body.lineHeight)/2,
                                        width,
                                        FCStyle.body.lineHeight)];
        };
        _label1.font = FCStyle.body;
        _label1.textColor = self.element.enable ? FCStyle.accent : FCStyle.fcSeparator;
        if (self.element.enable){
            _label1.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(region0Click:)];
            [_label1 addGestureRecognizer:tap];
        }
        [self.contentView addSubview:_label1];
    }
    
    return _label1;
}

- (FCLayoutLabel *)label2{
    if (nil == _label2){
        _label2 = [[FCLayoutLabel alloc] init];
        __weak ModalItemSplitView *weakSelf = self;
        _label2.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat width = [weakSelf.element.latestContentUserInfo[@"text2Width"] floatValue];
            [itself setFrame:CGRectMake(superView.width/2 + (superView.width/2 - width) / 2,
                                        (superView.height - FCStyle.body.lineHeight)/2,
                                        width,
                                        FCStyle.body.lineHeight)];
        };
        _label2.font = FCStyle.body;
        _label2.textColor = self.element.enable ? FCStyle.accent : FCStyle.fcSeparator;
        if (self.element.enable){
            _label2.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(region1Click:)];
            [_label2 addGestureRecognizer:tap];
        }
        [self.contentView addSubview:_label2];
    }
    
    return _label2;
}

- (void)region0Click:(UITapGestureRecognizer *)tapGestureRecognizer{
    self.element.splitEntity.clickIndex = 0;
    if (self.element.action){
        self.element.action(self.element);
    }
}

- (void)region1Click:(UITapGestureRecognizer *)tapGestureRecognizer{
    self.element.splitEntity.clickIndex = 1;
    if (self.element.action){
        self.element.action(self.element);
    }
}

- (FCLayoutView *)lineView{
    if (nil == _lineView){
        _lineView = [[FCLayoutView alloc] init];
        _lineView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width/2,
                                        (superView.height - FCStyle.body.lineHeight)/2,
                                        0.5,
                                        FCStyle.body.lineHeight)];
        };
        _lineView.backgroundColor = FCStyle.fcSeparator;
        [self.contentView addSubview:_lineView];
    }
    
    return _lineView;
}

@end
