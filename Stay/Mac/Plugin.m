//
//  Plugin.m
//  Stay-Mac
//
//  Created by ris on 2022/6/20.
//

#import "Plugin.h"

@implementation Plugin

- (instancetype)init{
    if (self = [super init]){
    }
    
    return self;
}

- (void)load{
    NSString *bundleFileName = @"macOSNative.bundle";
    NSURL *bundleURL = [[[NSBundle mainBundle] builtInPlugInsURL] URLByAppendingPathComponent:bundleFileName];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    if (bundle){
        Class fcAppKitClass = [bundle classNamed:@"FCAppKit"];
        if (fcAppKitClass){
            self.appKit = [[fcAppKitClass alloc] initWithAppDelegate:self];
        }
        
        Class fcCarbonClass = [bundle classNamed:@"FCCarbon"];
        if (fcCarbonClass){
            self.carbon = [[fcCarbonClass alloc] init];
        }
    }
}

@end
