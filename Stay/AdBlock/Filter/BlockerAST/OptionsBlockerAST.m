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
    NSUInteger resourceTypesDefaultCount = resourceTypesDefault.count;
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
        else if (option.type == FilterOptionTypeScript){
            if (option.inverse){
                [inverseResourceTypes addObject:@"script"];
            }
            else{
                [resourceTypes addObject:@"script"];
            }
        }
        else if (option.type == FilterOptionTypeStylesheet){
            if (option.inverse){
                [inverseResourceTypes addObject:@"style-sheet"];
            }
            else{
                [resourceTypes addObject:@"style-sheet"];
            }
        }
        else if (option.type == FilterOptionTypeObject){
            if (option.inverse){
                [inverseResourceTypes addObject:@"raw"];
            }
            else{
                [resourceTypes addObject:@"raw"];
            }
        }
        else if (option.type == FilterOptionTypeXmlHttpRequest){
            if (option.inverse){
                [inverseResourceTypes addObject:@"fetch"];
            }
            else{
                [resourceTypes addObject:@"fetch"];
            }
        }
        else if (option.type == FilterOptionTypeSubDocument){
            if (option.inverse){
                [inverseResourceTypes addObject:@"document"];
            }
            else{
                [resourceTypes addObject:@"document"];
            }
        }
        else if (option.type == FilterOptionTypePing){
            if (option.inverse){
                [inverseResourceTypes addObject:@"ping"];
            }
            else{
                [resourceTypes addObject:@"ping"];
            }
        }
        else if (option.type == FilterOptionTypeWebSocket){
            if (option.inverse){
                [inverseResourceTypes addObject:@"websocket"];
            }
            else{
                [resourceTypes addObject:@"websocket"];
            }
        }
        else if (option.type == FilterOptionTypeDocument){
            if (option.inverse){
                [inverseResourceTypes addObject:@"document"];
            }
            else{
                [resourceTypes addObject:@"document"];
            }
        }
        else if (option.type == FilterOptionTypeElemHide){
            if (option.inverse){
                [inverseResourceTypes addObject:@"document"];
            }
            else{
                [resourceTypes addObject:@"document"];
            }
        }
        else if (option.type == FilterOptionTypePopup){
            if (option.inverse){
                [inverseResourceTypes addObject:@"popup"];
            }
            else{
                [resourceTypes addObject:@"popup"];
            }
        }
        else if (option.type == FilterOptionTypeFont){
            if (option.inverse){
                [inverseResourceTypes addObject:@"font"];
            }
            else{
                [resourceTypes addObject:@"font"];
            }
        }
        else if (option.type == FilterOptionTypeMedia){
            if (option.inverse){
                [inverseResourceTypes addObject:@"media"];
            }
            else{
                [resourceTypes addObject:@"media"];
            }
        }
        else if (option.type == FilterOptionTypeOther){
            if (option.inverse){
                [inverseResourceTypes addObject:@"other"];
            }
            else{
                [resourceTypes addObject:@"other"];
            }
        }
        else if (option.type == FilterOptionTypeThirdParty){
            [self addLoadType:option.inverse ? @"first-party" : @"third-party"];
        }
        else if (option.type == FilterOptionTypeMatchCase){
            if (!option.inverse){
                self.urlFilterIsCaseSensitive = YES;
            }
        }
    }
    
    for (NSString *inverseResourceType in inverseResourceTypes){
        [resourceTypesDefault removeObject:inverseResourceType];
    }
    
    if (resourceTypes.count == 0){
        if (resourceTypesDefault.count < resourceTypesDefaultCount){
            for (NSString *resourceType in resourceTypesDefault){
                [self addResourceType:resourceType];
            }
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
