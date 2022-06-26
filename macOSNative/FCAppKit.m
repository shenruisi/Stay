//
//  FCAppKit.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "FCAppKit.h"
#import <Cocoa/Cocoa.h>

@interface _CursorTextView : NSTextView
@end

@implementation _CursorTextView

- (void)mouseMoved:(NSEvent *)event{
    [[NSCursor arrowCursor] set];
}

- (void)cursorUpdate:(NSEvent *)event{
    [[NSCursor arrowCursor] set];
}

- (void)resetCursorRects{
    [self discardCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor arrowCursor]];
}
@end

@interface FCAppKit()

@property (nonatomic, strong) id<UINSApplicationDelegate> appDelegate;
@end

@implementation FCAppKit

- (instancetype)initWithAppDelegate:(id<UINSApplicationDelegate>)appDelegate{
    if (self = [super init]){
        self.appDelegate = appDelegate;
        NSLog(@"appkit loaded.");
    }
    
    return self;
}



- (NSWindow *)_findWindow:(NSString *)targetIdentifier{
    NSArray *windows = [[NSApplication sharedApplication] windows];
    for (NSWindow *window in windows){
        NSString *windowClass = NSStringFromClass(window.class);
        if ([windowClass isEqualToString:@"UINSWindow"]){
            NSString *identifier = [[window performSelector:@selector(delegate)] persistentIdentifier];
            if (nil == identifier){
                identifier = [[window performSelector:@selector(delegate)] performSelector:@selector(sceneIdentifier)];
            }
            if ([identifier isEqualToString:targetIdentifier]){
                return window;
            }
        }
    }
    return nil;
}

- (void)openWindow:(NSString *)targetIdentifier
   sceneIdentifier:(NSString *)sceneIdentifier
  activeScreenInfo:(NSDictionary *)activeScreenInfo
            opened:(BOOL)opened{
    NSWindow *window = [self _findWindow:targetIdentifier];
    if (window){
        if (!opened){
            NSString *key = [NSString stringWithFormat:@"3%@-%@",sceneIdentifier,[activeScreenInfo[@"id"] stringValue]];
            NSDictionary *frameActive = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (!frameActive){
                NSRect screenRect = NSMakeRect([activeScreenInfo[@"x"] floatValue],
                                         [activeScreenInfo[@"y"] floatValue],
                                         [activeScreenInfo[@"width"] floatValue],
                                         [activeScreenInfo[@"height"] floatValue]);
                [window setFrameOrigin:NSMakePoint(screenRect.origin.x + (screenRect.size.width - window.frame.size.width)/2,
                                                   (screenRect.size.height - window.frame.size.height)/2)];
                [[NSUserDefaults standardUserDefaults] setObject:@{@"x":@(window.frame.origin.x),
                                                                   @"y":@(window.frame.origin.y),
                                                                   @"width":@(window.frame.size.width),
                                                                   @"height":@(window.frame.size.height)
                                                                 }
                                                          forKey:key];
            }
            else{
                [window setFrame:NSMakeRect([frameActive[@"x"] floatValue],
                                            [frameActive[@"y"] floatValue],
                                            [frameActive[@"width"] floatValue],
                                            [frameActive[@"height"] floatValue])
                         display:YES];
            }
        }
        
        [window makeKeyAndOrderFront:nil];
    }
}

- (void)styleWindow:(NSString *)targetIdentifier origin:(NSDictionary *)origin{
    NSWindow *window = [self _findWindow:targetIdentifier];
    if (window){
        window.titlebarAppearsTransparent = YES;
        [window setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
//        if (origin && [origin[@"x"] floatValue] > 0 && [origin[@"y"] floatValue] > 0){
//            [window setFrameOrigin:NSMakePoint([origin[@"x"] floatValue], [origin[@"y"] floatValue])];
//        }
        
    }
}

- (void)topLevelWindow:(NSString *)targetIdentifier{
    NSWindow *window = [self _findWindow:targetIdentifier];
    if (window){
        [window setLevel:CGShieldingWindowLevel()];
    }
}

- (BOOL)titlebarAppearsTransparent:(NSString *)targetIdentifier{
    NSWindow *window = [self _findWindow:targetIdentifier];
    if (window){
        if (!window.titlebarAppearsTransparent){
            window.titlebarAppearsTransparent = YES;
        }
        return window.titlebarAppearsTransparent;
    }
    return NO;
}

- (NSToolbarItem *)appIcon:(NSString *)identifier imageData:(NSData *)imageData{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [imageView setImage:[[NSImage alloc] initWithData:imageData]];
    imageView.wantsLayer = YES;
    imageView.layer.cornerRadius = 5;
    imageView.layer.masksToBounds = YES;
    item.view = imageView;
    item.minSize = CGSizeMake(20, 20);
    item.maxSize = CGSizeMake(20, 20);
    return item;
}

- (NSToolbarItem *)appName:(NSString *)identifier{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    _CursorTextView *textView = [[_CursorTextView alloc] initWithFrame:NSMakeRect(0, 0, 65-10, 18)];
    [textView setString:@"Stay 2"];
    textView.font = [NSFont systemFontOfSize:14];
    textView.selectable = NO;
    textView.backgroundColor = [NSColor clearColor];
    textView.editable = NO;
    item.view = textView;
    return item;
}

- (NSToolbarItem *)labelItem:(NSString *)identifier text:(NSString *)text fontSize:(CGFloat)fontSize{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    _CursorTextView *textView = [[_CursorTextView alloc] initWithFrame:NSMakeRect(0, 0, 250, 20)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paraStyle.maximumLineHeight = 20;
    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName:paraStyle,
        NSFontAttributeName:[NSFont boldSystemFontOfSize:fontSize],
        NSForegroundColorAttributeName:[NSColor labelColor]
    } range:NSMakeRange(0, text.length)];
    [textView.textStorage setAttributedString:attributedString];
    textView.selectable = NO;
    textView.backgroundColor = [NSColor clearColor];
    textView.editable = NO;
    item.view = textView;
    
    return item;
}

- (void)labelItemChanged:(NSToolbarItem *)item text:(NSString *)text fontSize:(CGFloat)fontSize{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paraStyle.maximumLineHeight = 20;
    _CursorTextView *textView = (_CursorTextView *)item.view;
    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName:paraStyle,
        NSFontAttributeName:[NSFont boldSystemFontOfSize:fontSize],
        NSForegroundColorAttributeName:[NSColor labelColor]
    } range:NSMakeRange(0, text.length)];
    textView.selectable = NO;
    textView.backgroundColor = [NSColor clearColor];
    textView.editable = NO;
//    textView.textColor = [NSColor labelColor];
    [((NSTextView *)item.view).textStorage setAttributedString:attributedString];
}

- (NSToolbarItem *)slideTrackToolbarItem:(NSString *)identifier width:(CGFloat)width{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    item.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    item.view.wantsLayer = YES;
//    item.view.layer.backgroundColor = [NSColor yellowColor].CGColor;
    return item;
}

- (NSToolbarItem *)blockItem:(NSString *)identifier width:(CGFloat)width{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    item.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    item.view.wantsLayer = YES;
    return item;
}


- (void)slideTrackToolbarItemChanged:(NSToolbarItem *)item width:(CGFloat)width{
    item.minSize = CGSizeMake(width, 10);
    item.maxSize = CGSizeMake(width, 10);
}

@end
