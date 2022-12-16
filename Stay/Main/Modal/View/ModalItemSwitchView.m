//
//  ModalItemSwitchView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalItemSwitchView.h"
#import "FCLayoutSwitch.h"
#import "UIView+Layout.h"
#import "FCStyle.h"

@interface ModalItemSwitchView()

@property (nonatomic, strong) FCLayoutSwitch *switchView;
@end

@implementation ModalItemSwitchView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self switchView];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    self.switchView.on = element.switchEntity.on;
}

- (void)switchHandler:(UISwitch *)item{
    self.element.switchEntity.on = !self.element.switchEntity.on;
    if (self.element.action){
        self.element.action(self.element);
    }
}

- (FCLayoutSwitch *)switchView{
    if (nil == _switchView){
        _switchView = [[FCLayoutSwitch alloc] init];
        _switchView.onTintColor = FCStyle.accent;
        __weak ModalItemSwitchView *weakSelf = self;
        _switchView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - itself.frame.size.width,
                                        (superView.height - itself.frame.size.height) / 2,
                                        itself.frame.size.width,
                                        itself.frame.size.height)];
        };
        [_switchView addTarget:self action:@selector(switchHandler:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switchView];
    }
    
    return _switchView;
}

@end
