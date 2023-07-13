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
@property (nonatomic, strong) UIView *progressBackgroundView;
@property (nonatomic, strong) NSArray *nodeList;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
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


- (void)layoutSubviews {
    [super layoutSubviews];

    for(int i = 0;i < self.nodeViews.count; i++) {
        CAShapeLayer *nodeLayer = self.nodeViews[i];
        [nodeLayer removeFromSuperlayer];
    }
    
    
    CGFloat nodeSize = 13.0;
    // 创建节点视图并保存到数组
    int i = 0;
    
    for (NSNumber *positionNumber in @[@0, @0.25, @0.5,@0.75,@1]) {
        CGFloat position = [positionNumber floatValue];
        
        // 创建节点视图的圆形Layer
        CAShapeLayer *nodeLayer = [CAShapeLayer layer];
        nodeLayer.bounds = CGRectMake(0, 0, nodeSize, nodeSize);
        nodeLayer.position = CGPointMake(position * CGRectGetWidth(self.progressBackgroundView .bounds), CGRectGetHeight(self.progressBackgroundView .bounds) / 2.0);
        nodeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, nodeSize, nodeSize)].CGPath;
        nodeLayer.fillColor = FCStyle.progressBgColor.CGColor;
        
        if((_titleArray.count - 1) >= i) {
            bool finished = [_titleArray[i][@"finished"] boolValue];
            if(finished) {
                nodeLayer.fillColor = FCStyle.accent.CGColor;
                
                if(self.widthConstraint != NULL) {
                    [NSLayoutConstraint deactivateConstraints:@[
                        self.widthConstraint,
                    ]];
                    
                }
                self.widthConstraint =  [self.progressView.widthAnchor constraintEqualToConstant:((self.width - 48) / (self.nodeViews.count - 1)) * i];
                
                [NSLayoutConstraint activateConstraints:@[
                    self.widthConstraint,
                ]];
                
            }
        }
        i++;
        // 添加节点视图到进度条背景视图
        [self.progressBackgroundView.layer addSublayer:nodeLayer];
        if(self.nodeViews.count <= 4) {
            [self.nodeViews addObject:nodeLayer];
        }
    }
    
   
        
    
}

- (void)setupUI {
       // 创建进度条背景视图
    self.progressBackgroundView = [[UIView alloc] init];
    self.progressBackgroundView .backgroundColor = FCStyle.progressBgColor;
    self.progressBackgroundView .translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.progressBackgroundView ];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.progressBackgroundView .topAnchor constraintEqualToAnchor:self.topAnchor constant:19],
        [self.progressBackgroundView .leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24],
        [self.progressBackgroundView .trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24],
        [self.progressBackgroundView .heightAnchor constraintEqualToConstant:7],
    ]];
    
       
   
       
       // 创建进度条视图
    self.progressView = [[UIView alloc] init];
    self.progressView.backgroundColor = FCStyle.accent;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressBackgroundView  addSubview:self.progressView];
       
    [NSLayoutConstraint activateConstraints:@[
        [self.progressView.topAnchor constraintEqualToAnchor:self.progressBackgroundView.topAnchor],
        [self.progressView.heightAnchor constraintEqualToConstant:7],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.progressBackgroundView.leadingAnchor],
    ]];
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
        title.centerX = nodeLayer.bounds.origin.x + 24 + (self.width - 48) / 4.0 * i;
        [self addSubview:title];
        
        
        bool finished = [_titleArray[i][@"finished"] boolValue];
        if(finished) {
            nodeLayer.fillColor = FCStyle.accent.CGColor;
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
