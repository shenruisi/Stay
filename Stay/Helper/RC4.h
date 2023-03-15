//
//  RC4.h
//  Stay
//
//  Created by ris on 2023/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RC4 : NSObject

- (instancetype)initWithKey:(NSData *)key;
- (NSData *)encrypt:(NSData *)plaintext;
- (NSData *)decrypt:(NSData *)ciphertext;

@end


NS_ASSUME_NONNULL_END
