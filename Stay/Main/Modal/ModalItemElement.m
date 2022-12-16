//
//  ModalItemElement.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import "ModalItemElement.h"
#import "FCStyle.h"

@implementation ModalItemDataEntityGeneral
@end

@implementation ModalItemDataEntityIcon
@end

@implementation ModalItemDataEntitySwitch
@end

@implementation ModalItemDataEntityAccessory
@end

@implementation ModalItemDataEntitySplit
@end

@implementation ModalItemDataEntityInput
@end

@interface ModalItemElement()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *,NSNumber *> *cachedContentHeight;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *cachedContentUserInfo;
@end

@implementation ModalItemElement

- (instancetype)init{
    if (self = [super init]){
        self.spacing1 = 5;
        self.spacing2 = 10;
        self.spacing3 = 15;
        self.spacing4 = 20;
        self.tapEnabled = YES;
        self.enable = YES;
    }
    
    return self;
}

- (CGFloat)contentHeightWithWidth:(CGFloat)width{
    if (nil != self.cachedContentHeight[@(width)]){
        self.latestContentHeight = [self.cachedContentHeight[@(width)] floatValue];
        self.latestContentUserInfo = self.cachedContentUserInfo[@(width)];
        return self.latestContentHeight;
    }
    
    CGFloat contentWidth = 0;
    CGFloat contentHeight = [self baseHeight];
    NSMutableDictionary *contentUserInfo = [[NSMutableDictionary alloc] init];
    contentWidth = width - self.spacing3 -  self.spacing3;
    CGRect rect = [self.generalEntity.title boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName : FCStyle.body}
                                                   context:nil];
    contentUserInfo[@"titleWidth"] = @(rect.size.width);
    
    contentUserInfo[@"subtitleWidth"] = @(0);
    if (self.generalEntity.subtitle.length > 0){
        rect = [self.generalEntity.subtitle boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : FCStyle.footnote}
                                                       context:nil];
        contentUserInfo[@"subtitleWidth"] = @(rect.size.width);
    }
    
    if (self.generalEntity.tips.length > 0){
        rect = [self.generalEntity.tips boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName : FCStyle.footnote}
                                                         context:nil];
        CGFloat tipsHeight = 2 * self.spacing1 + ceilf(MIN(rect.size.height, FCStyle.footnote.lineHeight * 3));
        contentUserInfo[@"tipsHeight"] = @(tipsHeight);
        contentHeight += tipsHeight;
    }
    
    if (ModalItemElementTypeSplit == self.type){
        rect = [self.splitEntity.text1 boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : FCStyle.body}
                                                       context:nil];
        contentUserInfo[@"text1Width"] = @(rect.size.width);
        
        rect = [self.splitEntity.text1 boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : FCStyle.body}
                                                       context:nil];
        contentUserInfo[@"text2Width"] = @(rect.size.width);
    }
    
    self.cachedContentHeight[@(width)] = @(contentHeight);
    self.cachedContentUserInfo[@(width)] = contentUserInfo;
    self.latestContentHeight = contentHeight;
    self.latestContentUserInfo = contentUserInfo;
    return contentHeight;
}

- (CGFloat)baseHeight{
    return 45.0f;

}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)cachedContentHeight{
    if (nil == _cachedContentHeight){
        _cachedContentHeight = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedContentHeight;
}

- (NSMutableDictionary<NSNumber *,NSDictionary *> *)cachedContentUserInfo{
    if (nil == _cachedContentUserInfo){
        _cachedContentUserInfo = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedContentUserInfo;
}

- (void)clear{
    self.cachedContentHeight = nil;
    self.cachedContentUserInfo = nil;
}

@end
