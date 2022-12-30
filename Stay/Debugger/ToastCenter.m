//
//  ToastCenter.m
//  FastClip-iOS
//
//  Created by ris on 2022/3/4.
//

#import "ToastCenter.h"
#import "FCTopToast.h"

NSNotificationName const _Nonnull FCToastShouldShowNotification = @"app.fastclip.notification.FCToastShouldShowNotification";

@interface ToastCenter()

@property (nonatomic, strong) FCTopToast *topToast;
@end

@implementation ToastCenter

- (instancetype)init{
    if (self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(show:)
                                                     name:FCToastShouldShowNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)show:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    UIImage *icon = userInfo[@"icon"];
    NSString *mainTitle = userInfo[@"mainTitle"];
    NSString *secondaryTitle = userInfo[@"secondaryTitle"];
    [self.topToast showWithIcon:icon mainTitle:mainTitle secondaryTitle:secondaryTitle];
}

- (void)show:(nullable UIImage *)icon mainTitle:(NSString *)mainTitle secondaryTitle:(NSString *)secondaryTitle{
    if (![[NSThread currentThread] isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.topToast showWithIcon:icon mainTitle:mainTitle secondaryTitle:secondaryTitle];
        });
        return;
    }
    
    [self.topToast showWithIcon:icon mainTitle:mainTitle secondaryTitle:secondaryTitle];
}

- (FCTopToast *)topToast{
    if (nil == _topToast){
        _topToast = [[FCTopToast alloc] init];
    }
    
    return _topToast;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FCToastShouldShowNotification
                                                  object:nil];
}

@end
