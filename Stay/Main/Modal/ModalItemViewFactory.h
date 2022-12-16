//
//  ModalItemViewFactory.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import <Foundation/Foundation.h>
#import "ModalItemView.h"
#import "ModalItemElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModalItemViewFactory : NSObject

+ (ModalItemView *)ofElement:(ModalItemElement *)element;
@end

NS_ASSUME_NONNULL_END
