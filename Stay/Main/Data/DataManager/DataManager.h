//
//  DataManager.h
//  sqlite
//
//  Created by 朱凌云 on 16/3/18.
//  Copyright © 2016年 zly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+ (instancetype)shareManager;

- (NSArray *)findScript:(int)condition;

- (void)updateScrpitStatus:(int)status numberId:(int)numberId;

@end
