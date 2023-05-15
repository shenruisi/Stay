//
//  ContentBlockerRequestHandler.m
//  Stay Content Custom
//
//  Created by ris on 2023/4/12.
//

#import "ContentBlockerRequestHandler.h"
#import "ContentFilterManager.h"

@interface ContentBlockerRequestHandler ()

@end

@implementation ContentBlockerRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    NSURL *url = [[ContentFilterManager shared] ruleJSONURLOfFileName:@"Custom.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]
        || [[ContentFilterManager shared] ruleJSONStopped:@"Custom.json"]){
        url = [[NSBundle mainBundle] URLForResource:@"blockerList" withExtension:@"json"];
    }
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"blockerList" withExtension:@"json"];
    NSItemProvider *attachment = [[NSItemProvider alloc] initWithContentsOfURL:url];
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.attachments = @[attachment];
    
    [context completeRequestReturningItems:@[item] completionHandler:nil];
}

@end
