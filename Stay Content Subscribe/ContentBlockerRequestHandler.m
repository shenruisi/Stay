//
//  ContentBlockerRequestHandler.m
//  Stay Content Subscribe
//
//  Created by ris on 2023/6/1.
//

#import "ContentBlockerRequestHandler.h"
#import "ContentFilterManager.h"

@interface ContentBlockerRequestHandler ()

@end

@implementation ContentBlockerRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    NSURL *url = [[ContentFilterManager shared] ruleJSONURLOfFileName:@"Subscribe.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        url = [[NSBundle mainBundle] URLForResource:@"blockerList" withExtension:@"json"];
    }
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"blockerList" withExtension:@"json"];
    NSItemProvider *attachment = [[NSItemProvider alloc] initWithContentsOfURL:url];
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.attachments = @[attachment];
    
    [context completeRequestReturningItems:@[item] completionHandler:nil];
}

@end