//
//  AlertHelper.m
//  Stay
//
//  Created by ris on 2022/7/26.
//

#import "AlertHelper.h"

@implementation AlertHelper

+ (void)simpleWithTitle:(NSString *)title message:(NSString *)message inCer:(UIViewController *)cer{
    if (![[NSThread currentThread] isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                [cer.navigationController popViewControllerAnimated:YES];
                }];
            [alert addAction:conform];
            [cer presentViewController:alert animated:YES completion:nil];
        });
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        [cer.navigationController popViewControllerAnimated:YES];
        }];
    [alert addAction:conform];
    [cer presentViewController:alert animated:YES completion:nil];
}

@end
