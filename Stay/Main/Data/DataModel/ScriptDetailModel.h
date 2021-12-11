//
//  ScriptDetailModel.h
//  Stay
//
//  Created by zly on 2021/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptDetailModel : NSObject
@property(nonatomic, assign) int id_number;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *script_desc;
@property(nonatomic, strong) NSString *author;
@property(nonatomic, assign) int status;
@property(nonatomic, strong) NSString *script;

@end

NS_ASSUME_NONNULL_END
