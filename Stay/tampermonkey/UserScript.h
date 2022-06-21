//
//  UserScript.h
//  Stay
//
//  Created by ris on 2021/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//https://www.tampermonkey.net/documentation.php
@interface UserScript : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *namespace;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *homepage;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSArray<NSString *> *includes;
@property (nonatomic, copy) NSArray<NSString *> *mathes;
@property (nonatomic, copy) NSArray<NSString *> *excludes;
@property (nonatomic, copy) NSString *runAt;
@property (nonatomic, copy) NSArray<NSString *> *grants;
@property (nonatomic, copy) NSArray<NSString *> *unsupportedGrants;
@property (nonatomic, assign) BOOL noFrames;
@property (nonatomic, assign) BOOL pass;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *parsedContent;
@property (nonatomic, copy) NSString *sourcePage;
@property (nonatomic, copy) NSString *updateUrl;
@property (nonatomic, copy) NSString *downloadUrl;

@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL updateSwitch;
@property (nonatomic, copy) NSArray<NSString *> *requireUrls;

@property (nonatomic, copy) NSArray<NSString *> *requireCodes;
@property (nonatomic, copy) NSDictionary *resourceUrls;
@property (nonatomic, copy) NSArray<NSString *> *notes;
@property (nonatomic, copy) NSDictionary<NSString *,NSDictionary *> *locales;
@property (nonatomic, copy) NSArray<NSString *> *excludeSites;
@property (nonatomic, copy) NSString *installType;

@property (nonatomic, copy) NSString *injectInto;

//Stay only
@property (nonatomic, copy) NSString *stayEngine;

+ (instancetype)ofDictionary:(NSDictionary *)dic;
- (NSDictionary *)toDictionary;

//Use the return value as a key of `locales`
+ (NSString *)localeCode;
+ (NSString *)localeCodeLanguageCodeOnly;
@end

NS_ASSUME_NONNULL_END
