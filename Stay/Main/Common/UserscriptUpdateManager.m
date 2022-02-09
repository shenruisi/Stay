//
//  UserscriptUpdateManager.m
//  Stay
//
//  Created by zly on 2022/2/7.
//

#import "UserscriptUpdateManager.h"
#import "DataManager.h"


@implementation UserscriptUpdateManager

+ (instancetype)shareManager {
    static UserscriptUpdateManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserscriptUpdateManager alloc] init];
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:groupPath]){
            [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        }
        
    });
    return instance;
}


- (void)updateResouse {
    NSArray *array = [[DataManager shareManager] findScript:1];
    if (array == nil || array.count == 0) {
        return;
    }
    for(int i = 0; i < array.count; i++) {
        UserScript *scrpit = array[i];
        if(scrpit != nil && scrpit.requireUrls != nil){
            NSString *groupPath = [[[NSFileManager defaultManager]
                         containerURLForSecurityApplicationGroupIdentifier:
                             @"group.com.dajiu.stay.pro"] path];
            
            for(int j = 0; j < scrpit.requireUrls.count; j++) {
                NSString *requireUrl = scrpit.requireUrls[j];
                NSString *fileName = requireUrl.lastPathComponent;
                NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit.uuid,fileName];
                if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                    NSURL *url = [NSURL URLWithString:requireUrl];
                    if([url.scheme containsString:@"stay"]) {
                        continue;
                    } else {
                        
                    }
                }
            }
        }
    }
    

}




@end
