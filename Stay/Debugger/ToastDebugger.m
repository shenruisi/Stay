//
//  AlertDebugger.m
//  Stay
//
//  Created by ris on 2022/11/25.
//

#import "ToastDebugger.h"
#import "FCTopToast.h"
#import "ImageHelper.h"
#import "FCStyle.h"

@interface ToastDebugger()

@property (class,readonly) FCTopToast *topToast;
@end

@implementation ToastDebugger

+ (void)log:(NSString *)message{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.topToast showWithIcon:[ImageHelper sfNamed:@"ladybug" font:FCStyle.sfActbar color:FCStyle.fcBlack]
//                          mainTitle:NSLocalizedString(@"Debug", @"")
//                     secondaryTitle:message];
//    });
}

static FCTopToast *_kTopToast = nil;
+ (FCTopToast *)topToast{
    static dispatch_once_t onceTokenTopToast;
    dispatch_once(&onceTokenTopToast, ^{
        if (nil == _kTopToast){
            _kTopToast = [[FCTopToast alloc] initWithPermanent:YES];
        }
    });
    return _kTopToast;
}

@end
