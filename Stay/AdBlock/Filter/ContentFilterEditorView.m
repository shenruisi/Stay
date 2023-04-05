//
//  ContentFilterEditorView.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "ContentFilterEditorView.h"
#import "FCStyle.h"
#import "UIFont+Convert.h"

@implementation ContentFilterTextView

@end

@interface ContentFilterEditorView()<
 UITextViewDelegate
>

@end

@implementation ContentFilterEditorView

- (instancetype)init{
    if (self = [super init]){
        [self textView];
    }
    
    return self;
}

- (void)setStrings:(NSString *)strings{
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] init];
    NSArray<NSString *> *lines = [strings componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        NSMutableAttributedString *lineAttributedString;
        if (line.length == 0){
            lineAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{
                NSFontAttributeName : [FCStyle.body toHelvetica:0],
                NSForegroundColorAttributeName : FCStyle.fcBlack
             }];
        }
        else{
//            lineAttributedString = [MDMainLoop markdownString:line context:nil];
            [lineAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{
                NSFontAttributeName : [FCStyle.body toHelvetica:0],
                NSForegroundColorAttributeName : FCStyle.fcBlack
             }]];
        }
        [newAttributedString appendAttributedString:lineAttributedString];
    }
}

- (ContentFilterTextView *)textView{
    if (nil == _textView){
        _textView = [[ContentFilterTextView alloc] init];
        _textView.delegate = self;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textView.showsVerticalScrollIndicator = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;
        _textView.typingAttributes = @{
            NSForegroundColorAttributeName : FCStyle.fcBlack,
            NSFontAttributeName : [FCStyle.body toHelvetica:0],
            NSParagraphStyleAttributeName : paragraphStyle,
            NSKernAttributeName : @(0.5)
        };
        
        [self addSubview:_textView];
        [[_textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
        [[_textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
        [[_textView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        [[_textView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    }
    
    return _textView;
}

@end
