//
//  ContentFilterEditorView.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterTextView : UITextView
@end

@interface ContentFilterEditorView : FCView

@property (nonatomic, strong) ContentFilterTextView *textView;
@property (nonatomic, strong) NSString *strings;
@end

NS_ASSUME_NONNULL_END
