//
//  SYBrowseViewController.m
//  Stay
//
//  Created by zly on 2022/9/6.
//

#import "SYBrowseViewController.h"
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "JSDetailCell.h"
#import "UserscriptUpdateManager.h"
#import "BrowseView.h"
#import "ScriptMananger.h"
#import "FCStyle.h"
#import "SYExpandViewController.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "SYNetworkUtils.h"
#import "ScriptEntity.h"
#import "SYBrowseExpandViewController.h"
#import "SYNoDownLoadDetailViewController.h"
#import "BrowseDetailTableViewCell.h"
#import "SYEditViewController.h"
#import "LoadingSlideController.h"
#import <SafariServices/SafariServices.h>
#import "API.h"
#import "ImageHelper.h"
#import "FCStore.h"
#import "Tampermonkey.h"
#import "NSString+Urlencode.h"
#import "SharedStorageManager.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef FC_MAC
#import "ToolbarTrackView.h"
#import "FCSplitViewController.h"
#import "FCShared.h"
#import "Plugin.h"
#endif

#import "QuickAccess.h"
#import "DeviceHelper.h"

@interface _FeaturedBannerTableViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *entity;
@property (nonatomic, strong) UIScrollView *bannerView;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation _FeaturedBannerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = FCStyle.secondaryBackground;
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSArray *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    _entity = entity;
    NSArray *blocks = entity;
//    NSMutableArray *blocks = [NSMutableArray arrayWithObjects:entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0], nil];
    if(blocks.count == 0 ) {
        return;
    }
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, self.contentView.width - 30 , 56 + (self.contentView.width - 40) / 2.25F)];
    _bannerView.scrollEnabled = true;
    _bannerView.pagingEnabled = true;
    _bannerView.clipsToBounds = NO;
    _bannerView.showsVerticalScrollIndicator = false;
    _bannerView.showsHorizontalScrollIndicator = false;
    _bannerView.backgroundColor = FCStyle.secondaryBackground;
    CGFloat left = 0;
    for (int i = 0; i < blocks.count; i++) {
        UIView *banner = [self createBlockView:blocks[i]];
        
        banner.left = (banner.width + 10) * i + 20 ;
        
        [_bannerView addSubview:banner];
        left = banner.right;
    }
    
    _bannerView.contentSize = CGSizeMake(left ,56 + (self.contentView.width - 40) / 2.25F);
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 20, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  (self.contentView.width - 40) / 2.25F + 71;
    line.left = 20;
    [self.contentView addSubview:line];
    
    [self.contentView addSubview:_bannerView];
}

- (UIView *)createBlockView:(NSDictionary *)dic{
    NSString *title = @"title";
    NSString *subtitle = @"subtitle";
    if([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]){
        title = @"title_cn";
        subtitle = @"subtitle_cn";
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 56 + (self.contentView.width - 40) / 2.25F)];
    view.clipsToBounds = YES;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 22)];
    headerLabel.font = FCStyle.title3Bold;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[title];
    [view addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width- 40, 15)];
    subLabel.font = FCStyle.subHeadline;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[subtitle];
    subLabel.top = headerLabel.bottom + 5;
    [view addSubview:subLabel];
    
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, (self.contentView.width - 40) / 2.25F)];
    [bannerImageView sd_setImageWithURL:[NSURL URLWithString: dic[@"imageUrl"]]];
    bannerImageView.layer.cornerRadius = 10;
    bannerImageView.clipsToBounds = YES;
    bannerImageView.top = subLabel.bottom + 5;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerClick:)];
    objc_setAssociatedObject (tapGesture , @"url",  dic[@"jumpUrl"], OBJC_ASSOCIATION_COPY_NONATOMIC);
    [view addGestureRecognizer:tapGesture];
    
    bool border = [dic[@"border"] boolValue];
    if (border) {
        bannerImageView.layer.borderColor = FCStyle.borderColor.CGColor;
        bannerImageView.layer.borderWidth = 1;
    }
    
    [view addSubview:bannerImageView];
    view.backgroundColor = FCStyle.secondaryBackground;
    return view;
}

-(void)bannerClick:(id)tap {
    NSString *urlStr = objc_getAssociatedObject(tap,@"url");
    NSURL *url = [NSURL URLWithString:urlStr];
    if([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        if (FCDeviceTypeIPhone == DeviceHelper.type){
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            [_controller presentViewController:safariVc animated:YES completion:nil];
        }
        else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        }
       
#endif

    } else if([url.scheme isEqualToString:@"safari-http"] || [url.scheme isEqualToString:@"safari-https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif

    } else if([url.scheme isEqualToString:@"stay"]) {
        if([url.host isEqualToString:@"album"]) {
            SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
            
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];

            cer.url= [NSString stringWithFormat:@"https://api.shenyin.name/stay-fork/album/%@",str];
            
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                && [QuickAccess splitController].viewControllers.count >= 2){
                 [[QuickAccess secondaryController] pushViewController:cer];
            }
            else{
                 [self.navigationController pushViewController:cer animated:true];
            }
        } else if([url.host isEqualToString:@"userscript"]) {
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];
            ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[str];

            if(entity == nil) {
                SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
                cer.uuid = str;
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [self.navigationController pushViewController:cer animated:true];
                }
            } else {
                SYDetailViewController *cer = [[SYDetailViewController alloc] init];
                cer.script = [[DataManager shareManager] selectScriptByUuid:str];
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [self.navigationController pushViewController:cer animated:true];
                }
            }
        }
    } else {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif
    }
}


@end


@interface _FeaturedPromotedTableViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *entity;
@property (nonatomic, strong) UIScrollView *bannerView;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation _FeaturedPromotedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = FCStyle.secondaryBackground;
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSArray *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    _entity = entity;
    NSArray *blocks = entity;
//    NSMutableArray *blocks = [NSMutableArray arrayWithObjects:entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0], nil];
    if(blocks.count == 0 ) {
        return;
    }
    
    
    CGFloat width = (self.width - 50) / 2;
    
    if(blocks.count == 1) {
        width = self.width - 40;
    }
    
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.contentView.width - 30 , width / 1.8F)];
    _bannerView.clipsToBounds = NO;
    _bannerView.showsVerticalScrollIndicator = false;
    _bannerView.showsHorizontalScrollIndicator = false;
    _bannerView.backgroundColor = FCStyle.secondaryBackground;
    CGFloat left = 20;
    for (int i = 0; i < blocks.count; i++) {
        
        NSDictionary *dic = blocks[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width / 1.8F)];
        [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"imageUrl"]]];
        imageView.layer.cornerRadius = 10;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerClick:)];
        objc_setAssociatedObject (tapGesture , @"url",  dic[@"jumpUrl"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        [imageView addGestureRecognizer:tapGesture];
        
        bool border = [dic[@"border"] boolValue];
        if (border) {
            imageView.layer.borderColor = FCStyle.borderColor.CGColor;
            imageView.layer.borderWidth = 1;
        }
        
        imageView.left = left;
        
        [_bannerView addSubview:imageView];
        left = imageView.right + 10;
    }
    
//    _bannerView.contentSize = CGSizeMake(left ,56 + (self.contentView.width - 40) / 2.25F);
    
    UIImageView *promotedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    
    [promotedImageView setImage:[ImageHelper sfNamed:@"arrow.up.right.square.fill" font:FCStyle.footnote color:FCStyle.fcSecondaryBlack]];

    promotedImageView.top = _bannerView.bottom + 10;
    promotedImageView.left = 20;
    [self.contentView addSubview:promotedImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 320, 15)];
    titleLabel.text = NSLocalizedString(@"Promoted", @"");
    titleLabel.font = FCStyle.footnote;
    titleLabel.textColor = FCStyle.fcSecondaryBlack;
    titleLabel.left = promotedImageView.right + 2;
    titleLabel.bottom = promotedImageView.bottom;
    [self.contentView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 40, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  titleLabel.bottom + 10;
    line.left = 20;
    [self.contentView addSubview:line];
    
    [self.contentView addSubview:_bannerView];
}



-(void)bannerClick:(id)tap {
    NSString *urlStr = objc_getAssociatedObject(tap,@"url");
    NSURL *url = [NSURL URLWithString:urlStr];
    if([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        [_controller presentViewController:safariVc animated:YES completion:nil];
#endif

    } else if([url.scheme isEqualToString:@"safari-http"] || [url.scheme isEqualToString:@"safari-https"]) {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[urlStr stringByReplacingOccurrencesOfString:@"safari-" withString:@""] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif

    } else if([url.scheme isEqualToString:@"stay"]) {
        if([url.host isEqualToString:@"album"]) {
            SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
            
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];

            cer.url= [NSString stringWithFormat:@"https://api.shenyin.name/stay-fork/album/%@",str];
            #ifdef FC_MAC
                [[QuickAccess secondaryController] pushViewController:cer];
            #else
                [self.navigationController pushViewController:cer animated:true];
            #endif
        } else if([url.host isEqualToString:@"userscript"]) {
            NSString *str= [SYNetworkUtils getParamByName:@"id" URLString:url.absoluteString];
            ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[str];

            if(entity == nil) {
                SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
                cer.uuid = str;
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [self.navigationController pushViewController:cer animated:true];
                }
            } else {
                SYDetailViewController *cer = [[SYDetailViewController alloc] init];
                cer.script = [[DataManager shareManager] selectScriptByUuid:str];
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                     [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                     [self.navigationController pushViewController:cer animated:true];
                }
            }
        }
    } else {
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#endif
    }
}


@end



@interface _FeaturedAlubmTableViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *entity;
@property (nonatomic, strong) NSString *headTitle;
@property (nonatomic, strong) UIScrollView *bannerView;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) NSString *selectedUrl;

@end

@implementation _FeaturedAlubmTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = FCStyle.secondaryBackground;
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSArray *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    _entity = entity;
    NSArray *blocks = entity;

    if(blocks.count == 0 ) {
        return;
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 320, 22)];
    titleLabel.text = _headTitle;
    titleLabel.font = FCStyle.title3Bold;
    titleLabel.textColor = FCStyle.fcBlack;
    [self.contentView addSubview:titleLabel];
//    titleLabel.
    
    
    UIButton *seeAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [seeAllBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    [seeAllBtn setTitle:NSLocalizedString(@"SeeAll", @"") forState:UIControlStateNormal];
    seeAllBtn.frame = CGRectMake(0, 0, 100, 17);
    seeAllBtn.font = FCStyle.subHeadline;

    [seeAllBtn sizeToFit];
    seeAllBtn.centerY = titleLabel.centerY;
    seeAllBtn.right = self.contentView.width -11;
    
    [seeAllBtn addTarget:self action:@selector(clickSeeAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:seeAllBtn];
    
    long rowSize =  (blocks.count - 1) / 3 + 1;
    
    CGFloat width = self.contentView.width;
    if(rowSize >= 2) {
        width = self.contentView.width - 30;
    }
    CGFloat heigth = 174;
    if(blocks.count >= 3) {
        heigth = 78 * 3;
    } else {
        heigth = 78 * blocks.count;
    }
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, width , heigth)];
    _bannerView.scrollEnabled = true;
    _bannerView.pagingEnabled = true;
    _bannerView.clipsToBounds = NO;
    _bannerView.showsVerticalScrollIndicator = false;
    _bannerView.showsHorizontalScrollIndicator = false;
    _bannerView.backgroundColor = FCStyle.secondaryBackground;
    CGFloat left = 0;
  
    for (int i = 0; i < blocks.count; i+=3) {
        UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, heigth)];
        blockView.clipsToBounds = YES;
        for(int j = 0; j <= 2; j++) {
            if(i + j >= blocks.count) {
                break;
            }
            UIView *cellView = [self createCellView:blocks[i + j]];
            cellView.top = j * 78;
            [blockView addSubview:cellView];
        }
        blockView.left = (blockView.width + 10) * (i / 3) + 20 ;
        [_bannerView addSubview:blockView];
        left = blockView.right;
    }
    
    _bannerView.contentSize = CGSizeMake(left ,heigth);
    [self.contentView addSubview:_bannerView];
}

- (UIView *)createCellView:(NSDictionary *)dic{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 78)];
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 48, 48)];
    imageBox.layer.cornerRadius = 10;
    imageBox.layer.borderWidth = 1;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    imageView.contentMode =  UIViewContentModeScaleAspectFit;
    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];

    imageView.clipsToBounds = YES;
    imageView.centerX = 24;
    imageView.centerY = 24;
    [imageBox addSubview:imageView];
    [view addSubview:imageBox];
    view.backgroundColor = FCStyle.secondaryBackground;
    
    CGFloat left = 0;
    NSString *icon = dic[@"icon_url"];
    if( icon != nil && icon.length > 0){
        left = imageBox.right + 10;
    } else {
        imageBox.hidden = true;
    }
    
    NSString *name = @"name";
    NSString *desc = @"desc";

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 18)];
    headerLabel.font = FCStyle.bodyBold;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[name];
    [view addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 13)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[desc];
    subLabel.top = headerLabel.bottom + 5;
    [view addSubview:subLabel];
    headerLabel.left = subLabel.left = left;
    subLabel.top = headerLabel.bottom + 5;
    if( icon == nil || icon.length <= 0){
        headerLabel.width = 260;
        subLabel.width = 260;
    }
        
    NSDictionary *locate = dic[@"locales"];
    if(locate != NULL  && locate.count > 0) {
        NSDictionary *localLanguage = locate[[UserScript localeCode]];
        if (localLanguage != nil && localLanguage.count > 0) {
            headerLabel.text = localLanguage[name];
            subLabel.text = localLanguage[@"description"];
        }
    }
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 40 - 40 - 10, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  subLabel.bottom + 23.5;
    line.left = left;
    line.width = self.contentView.width - 40 - 10 - left;
    [view addSubview:line];
    
    NSString *uuid = dic[@"uuid"];
    
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 67, 25);
    btn.backgroundColor = FCStyle.background;
    if(entity != nil) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Detail", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.width = btn.width + 20;
        if(btn.width < 67) {
            btn.width = 67;
        }
        btn.height = 25;
        [btn addTarget:self.controller action:@selector(queryDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        
        NSString *btnName = NSLocalizedString(@"Get", @"");
        
        if (self.selectedUrl != nil && self.selectedUrl.length > 0 && [self.selectedUrl isEqualToString:dic[@"hosting_url"]]) {
            btnName = NSLocalizedString(@"Downloading", @"");
        }
        
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:btnName
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        objc_setAssociatedObject (btn , @"downloadUrl", dic[@"hosting_url"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"name", dic[@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"platforms", dic[@"platforms"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        [btn sizeToFit];
        btn.width = btn.width + 20;
        if(btn.width < 67) {
            btn.width = 67;
        }
        btn.height = 25;
        NSArray *plafroms = dic[@"platforms"];
        if (plafroms != NULL && ![plafroms containsObject:[[API shared] queryDeviceType]] ) {
            [btn addTarget:self.controller action:@selector(notSupport:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn addTarget:self.controller action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    btn.top = headerLabel.top;
    btn.right = self.contentView.width - 40 - 10;
    btn.layer.cornerRadius = 12.5;
    
    [view addSubview:btn];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noDownloadDetail:)];
    if(entity != nil) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(queryDetail:)];
        objc_setAssociatedObject (tapGesture , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    [tapGesture setName:uuid];
    
    [view addGestureRecognizer:tapGesture];
    
    headerLabel.width = subLabel.width = self.contentView.width - left - btn.width - 50 - 10;

    
    return view;
}
-(void)noDownloadDetail:(UITapGestureRecognizer *)tap {
    NSString* uuid = tap.name;
    SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
    cer.uuid = uuid;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
         [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
}

-(void)clickSeeAll:(id)sender{
    SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
    cer.data = self.entity;
    cer.title = self.headTitle;
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
         [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
    
}

@end

@interface BroSimpleLoadingView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)start;
- (void)stop;
@end

@implementation BroSimpleLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self indicator];
        [self label];
    }

    return self;
}

- (void)start{
    [self.superview bringSubviewToFront:self];
    self.hidden = NO;
    [self.indicator startAnimating];
}

- (void)stop{
    [self.superview sendSubviewToBack:self];
    self.hidden = YES;
    [self.indicator stopAnimating];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self.label sizeToFit];
    CGFloat width = self.indicator.frame.size.width + self.label.frame.size.width;
    CGFloat left = (self.frame.size.width - width) / 2;
    [self.indicator setFrame:CGRectMake(left,
                                        (self.frame.size.height - self.indicator.frame.size.height)/2,
                                        self.indicator.frame.size.width,
                                        self.indicator.frame.size.height)];
    [self.label setFrame:CGRectMake(self.indicator.frame.origin.x + self.indicator.frame.size.width + 15,
                                    (self.frame.size.height - self.label.frame.size.height)/2,
                                    self.label.frame.size.width,
                                    self.label.frame.size.height)];
    [self.indicator startAnimating];
}

- (UIActivityIndicatorView *)indicator{
    if (nil == _indicator){
        _indicator = [[UIActivityIndicatorView alloc] init];
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = FCStyle.body;
        _label.textColor = FCStyle.fcBlack;
        _label.text = NSLocalizedString(@"Loading", @"");
        [self addSubview:_label];
    }

    return _label;
}


- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];

}

@end

@interface SYBrowseViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UISearchControllerDelegate,
UIPopoverPresentationControllerDelegate
>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *datas; //featuredata
@property (nonatomic, strong) NSMutableArray *allDatas;
@property (nonatomic, strong) NSMutableArray *searchDatas;
//@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *allTableView;
@property (nonatomic, strong) UITableView *searchTableView;


@property (nonatomic, strong) BroSimpleLoadingView *simpleLoadingView;
@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger searchPageNo;

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, assign) bool inSearch;
@property (nonatomic, assign) bool allDataEnd;
@property (nonatomic, assign) bool allDataQuerying;
@property (nonatomic, assign) bool searchDataEnd;
@property (nonatomic, assign) bool searchDataQuerying;
@property (nonatomic, strong) NSString  *selectedUrl;


@end

@implementation SYBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    _selectedIdx = 0;
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
//    search.searchResultsUpdater = self;
    search.searchBar.placeholder = NSLocalizedString(@"SearchUserscripts", @"");
    self.navigationItem.searchController = search;
    self.navigationItem.searchController.delegate = self;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
    self.navigationItem.hidesSearchBarWhenScrolling = false;

    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:FCStyle.accent];
    [self.searchController.view addSubview:self.searchTableView];
    // Do any additional setup after loading the view.
//    [self.view addSubview:self.segmentedControl];
    [self tableView];
    [self queryData];
    self.tableView.sectionHeaderTopPadding = 0;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTab) name:@"changeTab" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidAddHandler)
                                                 name:@"app.stay.notification.userscriptDidAddNotification"
                                               object:nil];
    
//
//      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidAddNotification"
                                                  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"changeTab"
                                                  object:nil];
}

- (void)changeTab {
    [self queryData];
}

- (void)userscriptDidAddHandler{
    dispatch_async(dispatch_get_main_queue(),^{
        [[ScriptMananger shareManager] refreshData];
            [self reloadAllTableview];
    });
}
                   

//- (void)keyboardWillShow:(NSNotification *)notification{
//
// //会有人问为什么是tableview而不是view，因为tableview是最外层，你的textField也是加在tableview上
//
//   CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];//获取键盘高度
//   CGFloat keyboardTop = keyboardRect.size.height;//用于跟textField的y比较
//
//    self.searchTableView.height = self.searchTableView.height - keyboardTop;
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification{
//    self.searchTableView.height = self.searchController.view.height;
//}

- (UIView *)createTableHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 10+ 10 + 30)];
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"Featured", @""),NSLocalizedString(@"All", @""),nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:FCStyle.accent,NSFontAttributeName:FCStyle.footnoteBold} forState:UIControlStateSelected];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:FCStyle.fcBlack,NSFontAttributeName:FCStyle.footnoteBold} forState:UIControlStateNormal];
    segmentedControl.backgroundColor = FCStyle.secondaryPopup;
    segmentedControl.selectedSegmentTintColor = FCStyle.fcWhite;
    segmentedControl.selectedSegmentIndex = _selectedIdx;
    CGFloat left = (self.view.width - 200) / 2;
    segmentedControl.frame =  CGRectMake(left, 10, 200, 30);
    [segmentedControl addTarget:self action:@selector(segmentControllerAction:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segmentedControl];
    view.backgroundColor = FCStyle.background;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top = 49.5;
    [view addSubview:line];
    return  view;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.searchTableView.frame = self.view.bounds;
    self.allTableView.frame = self.view.bounds;
    [self reloadAllTableview];
}

- (void)reloadAllTableview {
    [self.tableView reloadData];
    [self.searchTableView reloadData];
    [self.allTableView reloadData];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    return;
}

#pragma mark -searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    _inSearch = false;
    [_searchDatas removeAllObjects];
    [self.searchTableView reloadData];
//    [self.tableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    _searchPageNo = 1;
    _inSearch = true;
    [self.searchTableView reloadData];
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchDatas removeAllObjects];
    if(searchText.length > 0) {
        _searchPageNo = 1;
        _searchDataEnd = false;
//        [_results addObjectsFromArray:[[DataManager shareManager] selectScriptByKeywordByAdded:searchText]];
       [self querySearchData:searchText];
    }
    [self.searchTableView reloadData];
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return nil;
    } else {
        return [self createTableHeaderView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return self.searchDatas.count;
    } else if([tableView isEqual:self.allTableView]) {
        return  self.allDatas.count;
    } else if([tableView isEqual:self.tableView]){
        return  self.datas.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView]) {
        NSDictionary *dic = self.datas[indexPath.row];
        if([dic[@"type"] isEqualToString:@"banner"]) {
            _FeaturedBannerTableViewCell *cell = [[_FeaturedBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
            cell.contentView.width = self.view.width;
            cell.width = self.view.width;
            cell.controller = self;
            cell.navigationController = self.navigationController;
            cell.entity = dic[@"blocks"];
            cell.contentView.backgroundColor = FCStyle.secondaryBackground;
            return cell;
        } else if([dic[@"type"] isEqualToString:@"album"]){
            _FeaturedAlubmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellALBUM"];
            if (cell == nil) {
                cell = [[_FeaturedAlubmTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellALBUM"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.contentView.width = self.view.width;
            cell.width = self.view.width;
            cell.controller = self;
            cell.navigationController = self.navigationController;
            
            NSString *title = @"title";
            if([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]){
                title = @"title_cn";
            }
            cell.headTitle = dic[title];
            cell.selectedUrl = _selectedUrl;
            cell.entity = dic[@"userscripts"];
            cell.contentView.backgroundColor = FCStyle.secondaryBackground;
            return cell;
        } else if([dic[@"type"] isEqualToString:@"promoted"]){
            _FeaturedPromotedTableViewCell *cell = [[_FeaturedPromotedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
            cell.contentView.width = self.view.width;
            cell.width = self.view.width;
            cell.controller = self;
            cell.navigationController = self.navigationController;
            cell.entity = dic[@"blocks"];
            cell.contentView.backgroundColor = FCStyle.secondaryBackground;
            return cell;
        }else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID3"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID3"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.contentView.backgroundColor = FCStyle.secondaryBackground;
            return cell;
        }
    } else if ([tableView isEqual:self.searchTableView]) {
        BrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIBD"];
        if (cell == nil) {
            cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIBD"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentView.width = self.view.width;
        cell.controller = self;
        cell.selectedUrl = _selectedUrl;
        cell.navigationController = self.navigationController;
        cell.entity = self.searchDatas[indexPath.row];
        return cell;
    } else  if([tableView isEqual:self.allTableView]){
        BrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIBD"];
        if (cell == nil) {
            cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIBD"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.contentView.width = self.view.width;
        cell.controller = self;
        cell.selectedUrl = _selectedUrl;
        cell.navigationController = self.navigationController;
        cell.entity = self.allDatas[indexPath.row];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID3"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentView.backgroundColor = FCStyle.secondaryBackground;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.searchTableView]) {
        return 138.0f;
    }else if([tableView isEqual:self.allTableView]) {
        return 138.0f;
    } else {
        NSDictionary *dic = self.datas[indexPath.row];
        if([dic[@"type"] isEqualToString:@"banner"]) {
            return (self.view.width - 40) / 2.25f + 72.0f;
        } else if([dic[@"type"] isEqualToString:@"album"]) {
            NSArray *array =  dic[@"userscripts"];
            if(array.count >= 3) {
                return 33 + 78 * 3;
            } else {
                return 33 + 78 * array.count;
            }
        } else if([dic[@"type"] isEqualToString:@"promoted"]) {
            NSArray *blocks = dic[@"blocks"];
            if(blocks != nil) {
                if (blocks.count == 1) {
                    return 17 + 35 + (self.view.width - 40) / 1.8f;
                } else {
                    return 17 + 35 + (self.view.width - 50) / 2 / 1.8f ;
                }
            }
        }
        
        return 1.0f;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBarAppearance *appearance =[UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    [[ScriptMananger shareManager] refreshData];
    [self reloadAllTableview];
}

- (void)queryData{
    if (self.datas.count == 0){
        [self.simpleLoadingView start];
    }
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        NSLocale *locale = [NSLocale currentLocale];

        [[SYNetworkUtils shareInstance] requestPOST:@"https://api.shenyin.name/stay-fork/browse/featured" params:@{@"client":@{@"pro":[[FCStore shared] getPlan:NO] == FCPlan.None?@false:@true,@"country":locale != nil?locale.countryCode:@"",@"device_type":[[API shared] queryDeviceType]}} successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            
            
            NSMutableArray *array = dic[@"biz"];
            
            NSMutableArray *finalArray = [NSMutableArray array];
            
            if(array != NULL && array.count > 0) {
                for(int i = 0;i < array.count; i++){
                    NSDictionary *dic = array[i];
                    if ([dic[@"type"] isEqualToString:@"promoted"] && !([[FCStore shared] getPlan:NO] == FCPlan.None)) {
                        continue;
                    } else {
                        [finalArray addObject:dic];
                    }
                }
            }
    
            self.datas = finalArray;
            dispatch_async(dispatch_get_main_queue(),^{
                [self.simpleLoadingView stop];
                [self.tableView reloadData];
            });
        } failBlock:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self.simpleLoadingView stop];
                [self.tableView reloadData];
            });
        }];

  
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return 0.1;
    }
    return 50;
}

- (void)queryAllData{
    if (self.allDatas.count == 0){
        [self.simpleLoadingView start];
    }
    
    if(_allDataQuerying) {
            return;
    }
    _allDataQuerying = true;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        
        [[SYNetworkUtils shareInstance] requestGET:[NSString stringWithFormat: @"https://api.shenyin.name/stay-fork/browse/all?page=%ld",_pageNo] params:nil successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            if(_pageNo == 1) {
                _allDataEnd = false;
                [self.allDatas removeAllObjects];
            }
            _allDataQuerying = false;
            NSArray *array = dic[@"biz"];
            if(array.count == 0) {
                _allDataEnd = true;
            }
            [self.allDatas addObjectsFromArray:dic[@"biz"]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.allTableView reloadData];
                    });
                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.allTableView reloadData];
                    });
                    _allDataQuerying = false;
                }];

  
    });
}

- (void)querySearchData:(NSString *)key{
    if(_searchDataQuerying) {
        return;
    }
    
    _searchDataQuerying = true;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        [[SYNetworkUtils shareInstance] requestPOST:[NSString stringWithFormat: @"https://api.shenyin.name/stay-fork/search?page=%d",_searchPageNo] params:@{@"biz":@{@"keywords":key}} successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            if(_searchPageNo == 1) {
                [self.searchDatas removeAllObjects];
            }
            _searchDataQuerying = false;
            
            NSArray *array = dic[@"biz"];
            if(array.count == 0) {
                _searchDataEnd = true;
            }
            
            [self.searchDatas addObjectsFromArray:dic[@"biz"]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.searchTableView reloadData];
                    });
                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.searchTableView reloadData];
                    });
                    
                    _searchDataQuerying = false;
                }];
    });
}


- (void)getDetail:(UIButton *)sender {

//    [sender setTitle:@"下载中" forState:UIControlStateNormal];
    
    NSString *url = objc_getAssociatedObject(sender,@"downloadUrl");
    NSString *name = objc_getAssociatedObject(sender,@"name");
    NSArray *platforms = objc_getAssociatedObject(sender,@"platforms");

    _selectedUrl = url;
    [self reloadAllTableview];

    self.loadingSlideController.originSubText = name;
    [self.loadingSlideController show];


    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:str];

        NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
        NSString *uuid = [self md5HexDigest:uuidName];
        userScript.uuid = uuid;
        userScript.active = true;
        userScript.downloadUrl = url;
        userScript.plafroms = platforms;
        _selectedUrl = nil;
        BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
        BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];
        if(!saveSuccess || !saveResourceSuccess) {
            [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                if (self.loadingSlideController.isShown){
                    [self.loadingSlideController dismiss];
                    self.loadingSlideController = nil;
                }
                [self reloadAllTableview];
            });
            
            return;
        }
        if ([[DataManager shareManager] selectScriptByUuid:userScript.uuid].name.length == 0){
            [[DataManager shareManager] insertUserConfigByUserScript:userScript];
            NSNotification *notification = [NSNotification notificationWithName:@"scriptSaveSuccess" object:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
            NSNotification *addNotification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidAddNotification" object:nil userInfo:@{@"uuid":uuid}];
            [[NSNotificationCenter defaultCenter]postNotification:addNotification];
            dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
                NSString *url = [NSString stringWithFormat:@"%@%@",@"https://api.shenyin.name/stay-fork/install/",uuid];
                
                [[SYNetworkUtils shareInstance] requestGET:url params:nil successBlock:^(NSString * _Nonnull responseObject) {
                        NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
             
                        } failBlock:^(NSError * _Nonnull error) {
                          
                        }];
            });
            
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            if (self.loadingSlideController.isShown){
                [self.loadingSlideController dismiss];
                self.loadingSlideController = nil;
            }
            [self initScrpitContent];
            NSString *content =  NSLocalizedString(@"Created", @"");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
            [alert addAction:conform];
            [self presentViewController:alert animated:YES completion:nil];
        
            [self reloadAllTableview];
        });
    });
    
//    self.loadingSlideController.originSubText = name;
//    [self.loadingSlideController show];
//    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
//     [set addCharactersInString:@"#"];
//    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
//        dispatch_async(dispatch_get_main_queue(),^{
//            if(data != nil ) {
//
//                if (self.loadingSlideController.isShown){
//                    [self.loadingSlideController dismiss];
//                    self.loadingSlideController = nil;
//                }
//                NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                SYEditViewController *cer = [[SYEditViewController alloc] init];
//                cer.content = str;
//                cer.downloadUrl = downloadUrl;
//                cer.platforms = platforms;
//#ifdef FC_MAC
//                [[QuickAccess secondaryController] pushViewController:cer];
//#else
//                [self.navigationController pushViewController:cer animated:true];
//#endif
//
//            }
//            else{
//                [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
//                dispatch_get_main_queue(), ^{
//                    if (self.loadingSlideController.isShown){
//                        [self.loadingSlideController dismiss];
//                        self.loadingSlideController = nil;
//                    }
//                });
//            }
//        });
//    });
}

- (void)queryDetail:(id)sender {
    NSString *uuid = objc_getAssociatedObject(sender,@"uuid");
    UserScript *model = [[DataManager shareManager] selectScriptByUuid:uuid];
    SYDetailViewController *cer = [[SYDetailViewController alloc] init];
    cer.isSearch = false;
    cer.script = model;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
         [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
}

- (void)notSupport:(id)sender {
    NSString *name = objc_getAssociatedObject(sender,@"name");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:name
                                                                   message:NSLocalizedString(@"Not supported on this device", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
     CGRect bounds = scrollView.bounds;
     CGSize size = scrollView.contentSize;
     UIEdgeInsets inset = scrollView.contentInset;
     float y = offset.y + bounds.size.height - inset.bottom;
     float h = size.height;
     float reload_distance = 10;
    if ([scrollView isEqual:self.searchTableView] && self.searchController.searchBar.text.length > 0) {
        
        [self.searchController.searchBar.searchTextField resignFirstResponder];
    }
     if(y > h + reload_distance) {
        if(self.selectedIdx == 1 && !_allDataEnd && [scrollView isEqual:self.allTableView]) {
             if(_allDataQuerying) {
                     return;
             }
             _pageNo++;
            [self queryAllData];
        } else if([scrollView isEqual:self.searchTableView] && !_searchDataEnd  && self.searchController.searchBar.text.length > 0) {
            if(_searchDataQuerying) {
                return;
            }
            _searchPageNo++;
            [self querySearchData:self.searchController.searchBar.text];
        }
     }
}

- (void)segmentControllerAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    if(index == 1) {
        _selectedIdx = 1;
        if(self.allDatas.count > 0) {
            _pageNo = 1;
            [self queryAllData];
        } else {
            if(_allDatas.count == 0) {
                _pageNo = 1;
                [self queryAllData];
            }
        }
        self.allTableView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        [self queryData];
        _selectedIdx = 0;
        self.tableView.hidden = NO;
        self.allTableView.hidden = YES;
        [self.tableView reloadData];
    }
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = FCStyle.background;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (UITableView *)allTableView {
    if (_allTableView == nil) {
        _allTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _allTableView.delegate = self;
        _allTableView.dataSource = self;
        _allTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _allTableView.backgroundColor = FCStyle.background;
        _allTableView.sectionHeaderTopPadding = 0;
        _allTableView.hidden = true;
        [self.view addSubview:_allTableView];
    }
    return _allTableView;
}

- (UITableView *)searchTableView {
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc]initWithFrame:self.searchController.view.bounds style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.sectionHeaderTopPadding = 0;
        _searchTableView.backgroundColor = FCStyle.background;
    }
    return _searchTableView;
}

- (BroSimpleLoadingView *)simpleLoadingView{
    if (nil == _simpleLoadingView){
        _simpleLoadingView = [[BroSimpleLoadingView alloc] initWithFrame:CGRectMake(0,
                                                                                 (self.view.frame.size.height - 50) / 2,
                                                                                 self.view.frame.size.width, 50)];
        
        [self.view addSubview:_simpleLoadingView];
    }
    
    return _simpleLoadingView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _datas;
}

- (NSMutableArray *)allDatas {
    if (_allDatas == nil) {
        _allDatas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _allDatas;
}

- (NSMutableArray *)searchDatas {
    if (_searchDatas == nil) {
        _searchDatas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _searchDatas;
}

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}


- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

- (void)initScrpitContent{
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *script = datas[i];
            UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:script.uuid];
            info.content = [script toDictionary];
            [info flush];
            script.parsedContent = @"";
            script.otherContent = @"";
            [array addObject: [script toDictionary]];
        }
        [SharedStorageManager shared].userscriptHeaders.content = array;
        [[SharedStorageManager shared].userscriptHeaders flush];
        [[ScriptMananger shareManager] buildData];
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
