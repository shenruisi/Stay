//
//  OptionsBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "OptionsBlockerAST.h"
#import "FilterToken.h"

@implementation OptionsBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    NSMutableArray *resourceTypesDefault = [[NSMutableArray alloc] initWithObjects:
                                            @"document",
                                            @"image",
                                            @"style-sheet",
                                            @"script",
                                            @"font",
                                            @"raw",
                                            @"svg-document",
                                            @"media",
                                            @"popup",
                                            @"ping",
                                            @"fetch",
                                            @"websocket",
                                            nil];
    NSArray<FilterOption *> *array = ((NSDictionary *)self.parser.curToken.value)[@"options"];
    NSMutableArray *inverseResourceTypes = [[NSMutableArray alloc] init];
    NSMutableArray *resourceTypes = [[NSMutableArray alloc] init];
    for (FilterOption *option in array){
        if (option.type == FilterOptionTypeDomain){
            NSMutableArray<FilterOptionDomain *> *domains = option.domains;
            if (domains.count > 0){
                BOOL inverse = domains[0].inverse;
                for (FilterOptionDomain *domain in domains){
                    if (domain.inverse == inverse){
                        if (inverse){
                            [self addUnlessDomain:domain.value];
                        }
                        else{
                            [self addIfDomain:domain.value];
                        }
                    }
                }
            }
        }
        else if (option.type == FilterOptionTypeImage){
            if (option.inverse){
                [inverseResourceTypes addObject:@"image"];
            }
            else{
                [resourceTypes addObject:@"image"];
            }
        }
    }
    
    for (NSString *inverseResourceType in inverseResourceTypes){
        [resourceTypesDefault removeObject:inverseResourceType];
    }
    
    if (resourceTypes.count == 0){
        for (NSString *resourceType in resourceTypesDefault){
            [self addResourceType:resourceType];
        }
    }
    else{
        for (NSString *resourceType in resourceTypes){
            if ([resourceTypesDefault containsObject:resourceType]){
                [self addResourceType:resourceType];
            }
        }
    }
}

@end
