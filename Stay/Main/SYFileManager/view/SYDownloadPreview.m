//
//  SYDownloadPreview.m
//  Stay
//
//  Created by zly on 2023/1/18.
//

#import "SYDownloadPreview.h"
#import "FCStore.h"
@interface SYDownloadPreview()
@end

@implementation SYDownloadPreview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createView {
    CGFloat left = 15;
    CGFloat top = 100;
    CGFloat width = self.width - 10;
        
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, width,width / 388 * 378)];
    imageView1.image = [UIImage imageNamed:@"DownloadPreview1"];
    imageView1.layer.cornerRadius = 5;
    imageView1.clipsToBounds = YES;
    [self addSubview:imageView1];

    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(left + width + left, top, width,width / 388 * 378)];
    imageView2.image = [UIImage imageNamed:@"DownloadPreview2"];
    imageView2.layer.cornerRadius = 5;
    imageView2.clipsToBounds = YES;

    [self addSubview:imageView2];

    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(15 * 3 + width * 2 , top, width,width / 388 * 378)];
    imageView3.image = [UIImage imageNamed:@"DownloadPreview3"];
    imageView3.layer.cornerRadius = 5;
    imageView3.clipsToBounds = YES;
    imageView3.userInteractionEnabled = YES;

    [self addSubview:imageView3];

    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    
    if(isPro) {
        
    } else {
        
    }
}

- (void)createView:(NSString *)imageName {
    
    
}



@end
