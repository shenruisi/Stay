//
//  InputMenu.h
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "FCSlideController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol InputMenuHosting <NSObject>

- (BOOL)canUndo;
- (BOOL)canRedo;
- (BOOL)canClear;
- (void)resignFirstResponder;
- (void)undo;
- (void)redo;
- (void)clear;
@end

@interface InputMenu : FCSlideController

@property (nonatomic, weak) id<InputMenuHosting> hosting;
@end

NS_ASSUME_NONNULL_END
