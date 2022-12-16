//
//  ModalItemViewFactory.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import "ModalItemViewFactory.h"
#import "ModalItemClickView.h"
#import "ModalItemClickWithIconView.h"
#import "ModalItemSwitchView.h"
#import "ModalItemSplitView.h"
#import "ModalItemAccessoryWithTextView.h"
#import "ModalItemInputView.h"
#import "ModalItemAccessoryView.h"

@implementation ModalItemViewFactory

+ (ModalItemView *)ofElement:(ModalItemElement *)element{
    if (ModalItemElementTypeClick == element.type){
        return [[ModalItemClickView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeClickWithIcon == element.type){
        return [[ModalItemClickWithIconView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeSwitch == element.type){
        return [[ModalItemSwitchView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeSplit == element.type){
        return [[ModalItemSplitView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeAccessory == element.type){
        return [[ModalItemAccessoryView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeAccessoryWithText == element.type){
        return [[ModalItemAccessoryWithTextView alloc] initWithElement:element];
    }
    else if (ModalItemElementTypeInput == element.type){
        return [[ModalItemInputView alloc] initWithElement:element];
    }
    
    return nil;
}

@end
