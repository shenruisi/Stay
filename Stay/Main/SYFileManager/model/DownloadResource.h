//
//  DownloadResource.h
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadResource : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *icon;
@property(nonatomic, copy) NSString *host;
@property(nonatomic, copy) NSString *downloadUrl;
@property(nonatomic, copy) NSString *downloadUuid;
//0是下载中,1是已暂停,2是下载完成,3是下载失败,4是转码中,5是转码失败,6是空间不足
@property(nonatomic, assign) NSInteger status;
@property(nonatomic, assign) float downloadProcess;
@property(nonatomic, assign) NSInteger watchProcess;
@property(nonatomic, assign) NSInteger videoDuration;
@property(nonatomic, copy) NSString *firstPath;
@property(nonatomic, copy) NSString *allPath;
@property(nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *createTime;
@property(nonatomic, assign) NSInteger sort;
@property (nonatomic, copy) NSDictionary *useInfo;

@end

NS_ASSUME_NONNULL_END
