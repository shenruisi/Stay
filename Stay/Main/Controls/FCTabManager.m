//
//  FCTabManager.m
//  FastClip-iOS
//
//  Created by ris on 2022/1/20.
//

#import "FCTabManager.h"


@interface FCTabManager(){
}

@property (nonatomic, strong) NSMutableArray<FCTab *> *tabs;
@end

@implementation FCTabManager

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc{
}

- (FCTab *)newTab{
    return [self addTabWithUUID:[[NSUUID UUID] UUIDString]];
}

- (FCTab *)addTabWithUUID:(NSString *)uuid{
    FCTab *tab;
    @synchronized (self.tabs) {
        tab = [[FCTab alloc] initWithUUID:uuid];
        tab.config.position = self.tabs.count;
        [self.tabs addObject:tab];
    }
    [tab flush];
    return tab;
}

- (FCTab *)tabOfUUID:(NSString *)uuid{
    FCTab *found;
   
    @synchronized (self.tabs) {
        for (FCTab *tab in self.tabs){
            if ([tab.uuid isEqualToString:uuid]){
                found = tab;
                break;
            }
        }
    }
    
    return found;
}

- (void)deleteTab:(FCTab *)tab{
    [self deleteTabWithUUID:tab.uuid];
}

- (void)deleteTabWithUUID:(NSString *)uuid{
    @synchronized (self.tabs) {
        for (FCTab *tab in self.tabs){
            if ([tab.uuid isEqualToString:uuid]){
                [tab remove];
                [self.tabs removeObject:tab];
                break;
            }
        }
    }
}

- (NSMutableArray<FCTab *> *)tabs{
    if (nil == _tabs){
        _tabs = [[NSMutableArray alloc] init];
        NSArray<NSString *> *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:FCTabDirectory() error:nil];
        
        for (NSString *subpath in subpaths){
            if ([subpath hasPrefix:@"."]) continue;
            @synchronized (self.tabs) {
                FCTab *tabOnDisk = [self tabOfUUID:subpath];
                if (nil == tabOnDisk){
                    [_tabs addObject:[[FCTab alloc] initWithUUID:subpath]];
                }
            }
        }
        
        if (_tabs.count == 0) {
            FCTab *tab = [self newTab];
            tab.config.name = NSLocalizedString(@"Default", @"");
            tab.config.hexColor = @"B620E0";
        } else {
            [_tabs sortUsingComparator:^NSComparisonResult(FCTab *  _Nonnull tab1, FCTab *  _Nonnull tab2) {
                return tab1.config.position - tab2.config.position;
            }];
        }
    }
    
    return _tabs;
}

- (void)resetAllTabs{
    _tabs = nil;
}

- (NSString *)tabNameWithUUID:(NSString *)uuid{
    FCTab *tab = [self tabOfUUID:uuid];
    
    return tab.config.name;
}

@end
