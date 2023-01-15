//
//  M3U8LineReader.m
//  M3U8Kit
//
//  Created by Noam Tamim on 22/03/2018.
//

#import "M3U8LineReader.h"


@implementation M3U8LineReader
- (instancetype)initWithText:(NSString*)text
{
    self = [super init];
    if (self) {
        _lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    return self;
}

- (NSString*)next {
    while (_index < _lines.count) {
        NSString* line = [_lines[_index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _index++;
        
        if (line.length > 0) {
            return line;
        }
    }
    return nil;
}
@end

