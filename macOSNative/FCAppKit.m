//
//  FCAppKit.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "FCAppKit.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "UINSApplicationDelegate.h"

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
        NSString *mode = [[NSUserDefaults standardUserDefaults] objectForKey:@"macOSNative.appearance"];
        if (mode.length == 0){
            mode = @"System";
        }
        [self appearanceChanged:mode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterFullScreenHandler:)
                                                     name:NSWindowWillEnterFullScreenNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willExitFullScreenHandler:)
                                                     name:NSWindowWillExitFullScreenNotification
                                                   object:nil];
        
        
    }
    
    return self;
}


- (void)willEnterFullScreenHandler:(NSNotification *)note{
    [self.appDelegate willEnterFullScreen];
}

- (void)willExitFullScreenHandler:(NSNotification *)note{
    [self.appDelegate willExitFullScreen];
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

- (void)changeAppIcon:(NSToolbarItem *)item imageData:(NSData *)imageData{
    NSImageView *imageView = (NSImageView *)item.view;
    [imageView setImage:[[NSImage alloc] initWithData:imageData]];
    item.minSize = CGSizeMake(20, 20);
    item.maxSize = CGSizeMake(20, 20);
}

- (NSToolbarItem *)iCloudSync:(NSString *)identifier imageData:(NSData *)imageData{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(5, 0, 20, 20)];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIColorClamp"];
    NSString *colorString = [[NSUserDefaults standardUserDefaults] objectForKey:@"macOSNative.accentColor"];
    if (colorString.length == 0){
        colorString = @"#B620E0";
    }
    NSColor *accentColor = [self colorWithHexString:colorString alpha:1];
    NSColor *spaceColor = [accentColor colorUsingColorSpace:NSColorSpace.deviceRGBColorSpace];
    CGFloat redComponent = spaceColor.redComponent;
    CGFloat greenComponent = spaceColor.greenComponent;
    CGFloat blueComponent = spaceColor.blueComponent;
    CIVector *minVector = [[CIVector alloc] initWithX:redComponent Y:greenComponent Z:blueComponent W:0];
    CIVector *maxVector = [[CIVector alloc] initWithX:redComponent Y:greenComponent Z:blueComponent W:1];

    [colorFilter setDefaults];
    [colorFilter setValue:minVector forKey:@"inputMinComponents"];
    [colorFilter setValue:maxVector forKey:@"inputMaxComponents"];
    indicator.contentFilters = @[colorFilter];
    [indicator startAnimation:nil];
    item.view = indicator;
    item.minSize = CGSizeMake(25, 25);
    item.maxSize = CGSizeMake(25, 25);
    return item;
}

- (NSToolbarItem *)appName:(NSString *)identifier{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    _CursorTextView *textView = [[_CursorTextView alloc] initWithFrame:NSMakeRect(0, 0, 65-10, 18)];
    [textView setString:@"Stay"];
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

- (void)appearanceChanged:(NSString *)mode{
    if ([mode isEqualToString:@"System"]){
        NSAppearanceName appearanceName = [NSApp.effectiveAppearance bestMatchFromAppearancesWithNames:
                        @[ NSAppearanceNameAqua, NSAppearanceNameDarkAqua ]];
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:appearanceName];
    }
    else if ([mode isEqualToString:@"Dark"]){
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }
    else if ([mode isEqualToString:@"Light"]){
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mode forKey:@"macOSNative.appearance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)accentColorChanged:(NSString *)colorString{
    [[NSUserDefaults standardUserDefaults] setObject:colorString forKey:@"macOSNative.accentColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSColor *)colorWithHexString:(NSString *)string alpha:(CGFloat) alpha
{
    if ([string hasPrefix:@"#"])
        string = [string substringFromIndex:1];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    NSString *rString = [string substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [string substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [string substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [NSColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:alpha];
}

- (void)openUrl:(NSURL *)url {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    [ws openURLs: @[url] withAppBundleIdentifier:@"com.apple.Safari"
         options: NSWorkspaceLaunchDefault
    additionalEventParamDescriptor: NULL
    launchIdentifiers: NULL];
}


@end
