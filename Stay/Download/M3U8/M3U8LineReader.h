//
//  M3U8LineReader.h
//  M3U8Kit
//
//  Created by Noam Tamim on 22/03/2018.
//

#import <Foundation/Foundation.h>

@interface M3U8LineReader : NSObject
    
@property (nonatomic, readonly, strong) NSArray<NSString*>* lines;
@property (atomic, readonly, assign) NSUInteger index;
    
- (instancetype)initWithText:(NSString*)text;
- (NSString*)next;

@end
