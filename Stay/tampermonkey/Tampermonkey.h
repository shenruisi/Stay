//
//  Tampermonkey.h
//  Stay
//
//  Created by ris on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UserScript.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NativeExport <JSExport>

JSExportAs(nslog, - (void)nslog:(id)object);
@end

@interface Tampermonkey : NSObject<NativeExport>

+ (instancetype)shared;
- (UserScript *)parseScript:(NSString *)scriptName;
- (void)conventScriptContent:(UserScript *)userScript;
@end

NS_ASSUME_NONNULL_END
