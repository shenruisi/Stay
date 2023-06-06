//
//  FCSpeedTabBarItem.m
//  Stay
//
//  Created by ris on 2023/6/5.
//

#import "FCSpeedTabBarItem.h"
#import "DownloadManager.h"
#import "FCStyle.h"

@implementation FCSpeedTabBarItem

- (instancetype)initWithDescriptor:(NSDictionary *)descriptor{
    if (self = [super initWithDescriptor:descriptor]){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskDidStartHandler:)
                                                     name:DMTaskDidStartNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskSpeedHandler:)
                                                     name:DMTaskSpeedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskDidFinishHandler:)
                                                     name:DMTaskDidFinishNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)taskDidStartHandler:(NSNotification *)note{
    
}

- (void)taskSpeedHandler:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.button setImage:nil forState:UIControlStateSelected];
        [self.button setImage:nil forState:UIControlStateNormal];
        NSString *speed = note.userInfo[@"speed"];
        if (speed.length > 0){
            NSAttributedString *normalAttributedString = [[NSAttributedString alloc] initWithString:speed attributes:@{
                NSFontAttributeName : FCStyle.footnoteBold,
                NSForegroundColorAttributeName : FCStyle.fcThirdBlack
            }];
            
            NSAttributedString *selectedAttributedString = [[NSAttributedString alloc] initWithString:speed attributes:@{
                NSFontAttributeName : FCStyle.footnoteBold,
                NSForegroundColorAttributeName : FCStyle.accent
            }];
            
            [self.button setAttributedTitle:normalAttributedString forState:UIControlStateNormal];
            [self.button setAttributedTitle:selectedAttributedString forState:UIControlStateSelected];
        }
    });
    
}

- (void)taskDidFinishHandler:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.button setImage:self.selectImage forState:UIControlStateSelected];
        [self.button setImage:self.deselectImage forState:UIControlStateNormal];
        [self.button setAttributedTitle:nil forState:UIControlStateNormal];
        [self.button setAttributedTitle:nil forState:UIControlStateSelected];
    });
    
}

@end
