//
//  DownloadResource.m
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import "DownloadResource.h"

@implementation DownloadResource


- (id)copyWithZone:(nullable NSZone *)zone{
    DownloadResource *copyed = [[[self class] allocWithZone:zone] init];
    copyed.title = [self.title copy];
    copyed.icon = [self.icon copy];
    copyed.host = [self.host copy];
    copyed.downloadUrl = [self.downloadUrl copy];
    copyed.downloadUuid = [self.downloadUuid copy];
    copyed.status = self.status;
    copyed.downloadProcess = self.downloadProcess;
    copyed.watchProcess = self.watchProcess;
    copyed.videoDuration = self.videoDuration;
    copyed.firstPath = [self.firstPath copy];
    copyed.allPath = [self.allPath copy];
    copyed.type = [self.type copy];
    copyed.updateTime = [self.updateTime copy];
    copyed.createTime = [self.createTime copy];
    copyed.sort = self.sort;
    copyed.useInfo = [self.useInfo copy];
    copyed.audioUrl = [self.audioUrl copy];
    copyed.protect = self.protect;
    return copyed;
}


@end
