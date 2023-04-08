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
@property (nonatomic, strong) NSMutableArray *ifDomain;
@property (nonatomic, strong) NSMutableArray *unlessDomain;
@property (nonatomic, strong) NSMutableArray *resourceType;
@property (nonatomic, strong) NSMutableArray *loadType;
@property (nonatomic, strong) NSMutableArray *ifTopUrl;
@property (nonatomic, strong) NSMutableArray *unlessTopUrl;
@property (nonatomic, strong) NSMutableArray *loadContext;

//action


- (instancetype)initWithParser:(FilterTokenParser *)parser
                          args:(nullable NSArray *)args;
- (void)construct:(nullable NSArray *)args;
@end

NS_ASSUME_NONNULL_END
