//
//  SafariWebExtensionHandler.m
//  Stay Extension
//
//  Created by ris on 2021/10/15.
//

#import "SafariWebExtensionHandler.h"
#import "Stroge.h"
#import <SafariServices/SafariServices.h>

@implementation SafariWebExtensionHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    NSDictionary *message = (NSDictionary *)[context.inputItems.firstObject userInfo][SFExtensionMessageKey];
    NSExtensionItem *response = [[NSExtensionItem alloc] init];
    
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    
    id body = [NSNull null];
    if ([message[@"type"] isEqualToString:@"fetchScripts"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
        body = [[NSString alloc] initWithData:
                [NSJSONSerialization dataWithJSONObject:datas
                                                options:0
                                                  error:nil]
                                     encoding:NSUTF8StringEncoding];
    }
    else if ([message[@"type"] isEqualToString:@"GM_setValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        NSString *value = message[@"value"];
        if (uuid.length > 0 && key.length > 0 && value != nil){
            [Stroge setValue:value forKey:key uuid:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_getValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        id defaultValue = message[@"defaultValue"];
        if (uuid.length > 0 && key.length > 0){
            body = [Stroge valueForKey:key uuid:uuid defaultValue:defaultValue];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_deleteValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        if (uuid.length > 0 && key.length > 0){
            [Stroge deleteValueForKey:key uuid:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_listValues"]){
        NSString *uuid = message[@"uuid"];
        if (uuid.length > 0){
            body = [Stroge listValues:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"setScriptActive"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
            NSString *uuid = message[@"uuid"];
            Boolean activeVal = message[@"active"];
            
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [datas removeObject:dic];
                    [mdic setValue:@(activeVal) forKey:@"active"];
                    [datas addObject:mdic];
                    [groupUserDefaults setObject:datas forKey:@"ACTIVE_SCRIPTS"];
                    [groupUserDefaults synchronize];
                    break;
                }
            }
        }
        
        
        if([groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"] != NULL && [groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"].count > 0){
            NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"]];
            NSDictionary *dic = @{@"uuid":uuid,@"active":activeVal?@"1":@"0"};
            [datas addObject:dic];
            NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
            [groupUserDefaults setObject:datas forKey:@"ACTIVE_CHANGE"];
            [groupUserDefaults synchronize];
        } else {
            NSMutableArray<NSDictionary *> *datas = [[NSMutableArray alloc] init];
            NSDictionary *dic = @{@"uuid":uuid,@"active":activeVal?@"1":@"0"};
            [datas addObject:dic];
            NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
            [groupUserDefaults setObject:datas forKey:@"ACTIVE_CHANGE"];
            [groupUserDefaults synchronize];
        }
    }

    response.userInfo = @{ SFExtensionMessageKey: @{ @"type": message[@"type"],
                                                     @"body": body == nil ? [NSNull null]:body,
                                                    }
    };
    [context completeRequestReturningItems:@[ response ] completionHandler:nil];
}

@end
