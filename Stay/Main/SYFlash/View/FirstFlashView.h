//
//  FirstFlashView.h
//  Stay
//
//  Created by zly on 2022/7/24.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface FirstFlashView : UIScrollView


@property (nonatomic, assign) Boolean *activite;
@property (nonatomic, strong) NSArray *scriptList;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIButton *runBtn;
@property (nonatomic, strong) UIView *forPlayView;
@property (nonatomic, assign) NSInteger selectedCount;
@property (nonatomic, strong) NSString *guideUrl;

-(void)createFirstView;

@end

NS_ASSUME_NONNULL_END
