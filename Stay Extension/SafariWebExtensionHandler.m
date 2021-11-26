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
    NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
    id body = [NSNull null];
    if ([message[@"type"] isEqualToString:@"fetchScripts"]){
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
            // N activeVal = message[@"active"];
            if (uuid.length > 0){
                body = [Stroge listValues:uuid];
            }
        }

    response.userInfo = @{ SFExtensionMessageKey: @{ @"type": message[@"type"],
                                                     @"body": body == nil ? [NSNull null]:body,
                                                    }
    };
    [context completeRequestReturningItems:@[ response ] completionHandler:nil];
}

@end
