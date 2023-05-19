//
//  ContentBlockerRequestHandler.m
//  Stay Content Privacy Mac
//
//  Created by ris on 2023/5/18.
//

#import "ContentBlockerRequestHandler.h"
#import "ContentFilterManager.h"

@interface ContentBlockerRequestHandler ()

@end

@implementation ContentBlockerRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    NSURL *url = [[ContentFilterManager shared] ruleJSONURLOfFileName:@"Privacy.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]
        || [[ContentFilterManager shared] ruleJSONStopped:@"Privacy.json"]){
        url = [[NSBundle mainBundle] URLForResource:@"blockerList" withExtension:@"json"];
    }
    
    NSItemProvider *attachment = [[NSItemProvider alloc] initWithContentsOfURL:url];
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.attachments = @[attachment];
    
    [context completeRequestReturningItems:@[item] completionHandler:nil];
}

@end
