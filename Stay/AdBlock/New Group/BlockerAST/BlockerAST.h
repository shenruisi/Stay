//
//  BlockerAST.h
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import "FilterTokenParser.h"
NS_ASSUME_NONNULL_BEGIN

@interface BlockerAST : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *dictionary;
@property (nonatomic, strong) FilterTokenParser *parser;

//trigger
@property (nonatomic, strong) NSString *urlFilter;
@property (nonatomic, assign) BOOL urlFilterIsCaseSensitive;
- (void)addIfDomain:(NSString *)ifDomain;
- (void)addUnlessDomain:(NSString *)unlessDomain;
- (void)addResourceType:(NSString *)resourceType;
- (void)addLoadType:(NSString *)loadType;
- (void)addIfTopUrl:(NSString *)ifTopUrl;
- (void)addUnlessTopUrl:(NSString *)unlessTopUrl;
- (void)addLoadContext:(NSString *)loadContext;

//action
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *selector;


- (instancetype)initWithParser:(FilterTokenParser *)parser
                          args:(nullable NSArray *)args;
- (void)construct:(nullable NSArray *)args;
@end

NS_ASSUME_NONNULL_END
