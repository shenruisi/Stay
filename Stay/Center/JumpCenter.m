//
//  JumpCenter.m
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import "JumpCenter.h"
#import "DeviceHelper.h"
#ifdef FC_MAC
#import "ToolbarTrackView.h"
#import "FCSplitViewController.h"
#import "FCShared.h"
#import "Plugin.h"
#endif

#import <SafariServices/SafariServices.h>
#import "SYBrowseExpandViewController.h"
#import "SYNetworkUtils.h"
#import "QuickAccess.h"
#import "ScriptMananger.h"
#import "SYNoDownLoadDetailViewController.h"
#import "ScriptEntity.h"
#import "DataManager.h"
#import "SYInviteViewController.h"

@implementation JumpCenter

+ (void)jumpWithUrl:(NSString *)urlStr baseCer:(UIViewController *)baseCer{
    NSURL *url = [NSURL URLWithString:urlStr];
    if([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        if (FCDeviceTypeIPhone == DeviceHelper.type){
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            [baseCer presentViewController:safariVc animated:YES completion:nil];
        }
        else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        }
       
#endif

    } else if([url.scheme isEqualToString:@"safari-http"] || [url.scheme isEqualToString:@"safari-https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif

    } else if([url.scheme isEqualToString:@"stay"]) {
        if([url.host isEqualToString:@"album"]) {
            SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
            
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];

            cer.url= [NSString stringWithFormat:@"https://api.shenyin.name/stay-fork/album/%@",str];
            
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                && [QuickAccess splitController].viewControllers.count >= 2){
                 [[QuickAccess secondaryController] pushViewController:cer];
            }
            else{
                 [baseCer.navigationController pushViewController:cer animated:true];
            }
        } else if([url.host isEqualToString:@"userscript"]) {
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];
            ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[str];

            if(entity == nil) {
                SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
                cer.uuid = str;
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [baseCer.navigationController pushViewController:cer animated:true];
                }
            } else {
                SYDetailViewController *cer = [[SYDetailViewController alloc] init];
                cer.script = [[DataManager shareManager] selectScriptByUuid:str];
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [baseCer.navigationController pushViewController:cer animated:true];
                }
            }
        }
        else if ([url.host isEqualToString:@"gift"]){
            [baseCer.navigationController pushViewController:[[SYInviteViewController alloc] init] animated:YES];
        }
    } else {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif
    }
}

@end
