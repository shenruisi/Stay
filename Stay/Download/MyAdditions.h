//
//  MyAdditions.h
//  FastClip-iOS
//
//  Created by admin on 2021/4/1.
//

#ifndef MyAdditions_h
#define MyAdditions_h

@interface NSString (MyAdditions)
- (NSString *)md5;
@end

@interface NSData (MyAdditions)
- (NSString*)md5;
@end

#endif /* MyAdditions_h */
