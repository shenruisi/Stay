//
//  RC4.m
//  Stay
//
//  Created by ris on 2023/3/13.
//

#import "RC4.h"

@implementation RC4 {
    NSMutableArray *_S;
    NSMutableArray *_key;
}

- (instancetype)initWithKey:(NSData *)key {
    if (key.length < 1 || key.length > 256) {
        [NSException raise:@"Invalid key length" format:@"RC4: Invalid key length"];
    }
    self = [super init];
    if (self) {
        _S = [NSMutableArray arrayWithCapacity:256];
        _key = [NSMutableArray arrayWithCapacity:256];
        for (int i = 0; i < 256; i++) {
            _S[i] = @(i);
            _key[i] = @(((const uint8_t *)key.bytes)[i % key.length]);
        }

        int j = 0;
        for (int i = 0; i < 256; i++) {
            j = (j + [_S[i] intValue] + [_key[i] intValue]) % 256;
            [_S exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    return self;
}

- (NSData *)encrypt:(NSData *)plaintext {
    int i = 0;
    int j = 0;
    NSMutableData *ciphertext = [NSMutableData dataWithLength:plaintext.length];
    uint8_t *ciphertextBytes = ciphertext.mutableBytes;
    const uint8_t *plaintextBytes = plaintext.bytes;
    for (int n = 0; n < plaintext.length; n++) {
        i = (i + 1) % 256;
        j = (j + [_S[i] intValue]) % 256;
        [_S exchangeObjectAtIndex:i withObjectAtIndex:j];
        int k = [_S[([_S[i] intValue] + [_S[j] intValue]) % 256] intValue];
        ciphertextBytes[n] = plaintextBytes[n] ^ k;
    }
    return ciphertext;
}

- (NSData *)decrypt:(NSData *)ciphertext {
    return [self encrypt:ciphertext];
}

@end
