//
//  InviteProgressView.m
//  Stay
//
//  Created by zly on 2023/5/29.
//

#import "InviteProgressView.h"
#import "FCStyle.h"
@interface InviteProgressView ()

@property (nonatomic, strong) NSMutableArray *nodeViews;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) NSArray *nodeList;

@end
@implementation InviteProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.nodeViews = [NSMutableArray array];
        self.nodeList = @[@0, @0.25, @0.5,@0.75,@1];
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    CGFloat nodeSize = 13.0;
       
       // 创建进度条背景视图
    UIView *progressBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(24, 19,300 , 7)];
    progressBackgroundView.backgroundColor = FCStyle.progressBgColor;
    [self addSubview:progressBackgroundView];
       
   
       
       // 创建进度条视图
       self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,0 , 7)];
       self.progressView.backgroundColor = FCStyle.accent;
       [progressBackgroundView addSubview:self.progressView];
       
       
       // 创建节点视图并保存到数组
       for (NSNumber *positionNumber in @[@0, @0.25, @0.5,@0.75,@1]) {
            CGFloat position = [positionNumber floatValue];
             
            // 创建节点视图的圆形Layer
            CAShapeLayer *nodeLayer = [CAShapeLayer layer];
            nodeLayer.bounds = CGRectMake(0, 0, nodeSize, nodeSize);
            nodeLayer.position = CGPointMake(position * CGRectGetWidth(progressBackgroundView.bounds), CGRectGetHeight(progressBackgroundView.bounds) / 2.0);
            nodeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, nodeSize, nodeSize)].CGPath;
            nodeLayer.fillColor = FCStyle.progressBgColor.CGColor;

            // 添加节点视图到进度条背景视图
            [progressBackgroundView.layer addSublayer:nodeLayer];
            [self.nodeViews addObject:nodeLayer];
       }
}


- (void)updateProgress:(CGFloat)progress {
//    int index = progress / 0.25;
    for(int i = 0;i < self.nodeViews.count; i++) {
        CAShapeLayer *nodeLayer = self.nodeViews[i];
  
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 31, 19)];
        title.font = FCStyle.bodyBold;
        
        long point = [_titleArray[i][@"displayed_point_value"] longValue];
        
        NSNumber *number = [NSNumber numberWithLong:point];
        
        title.text = [number stringValue];
        title.textColor = FCStyle.fcBlack;
        title.textAlignment = NSTextAlignmentCenter;
        title.centerX = nodeLayer.bounds.origin.x + 24 + 75 * i;
        [self addSubview:title];
        
        
        bool finished = [_titleArray[i][@"finished"] boolValue];
        if(finished) {
            nodeLayer.fillColor = FCStyle.accent.CGColor;
            self.progressView.width = (300 / (self.nodeViews.count - 1)) * i;
        }
        
        
        
        if(i == (self.nodeViews.count - 1)) {
            title.textColor = FCStyle.fcOrangeColor;
        }
        
    }

    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
