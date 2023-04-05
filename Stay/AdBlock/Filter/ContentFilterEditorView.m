//
//  ContentFilterEditorView.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "ContentFilterEditorView.h"
#import "FCStyle.h"
#import "UIFont+Convert.h"
#import "ContentFilterHighlighter.h"

@implementation ContentFilterTextView

- (void)replaceSelectionWithAttributedText:(NSAttributedString *)text
{
    [self _replaceRange:self.selectedRange withAttributedText:text andSelectRange:NSMakeRange(self.selectedRange.location, text.length)];
}

- (void)replaceRange:(NSRange)range withAttributedText:(NSAttributedString *)text selection:(BOOL)selection{
    [self _replaceRange:range withAttributedText:text andSelectRange:NSMakeRange(selection ? range.location : range.location + text.length - 1, selection ? text.length : 0)];
}

- (void)replaceRange:(NSRange)range withAttributedText:(NSAttributedString *)text selectedRange:(NSRange)selectedRange
{
    [self _replaceRange:range withAttributedText:text andSelectRange:selectedRange];
}

- (void)_replaceRange:(NSRange)range withAttributedText:(NSAttributedString *)text andSelectRange:(NSRange)selection
{
    [[self.undoManager prepareWithInvocationTarget:self] _replaceRange:NSMakeRange(range.location, text.length)
                                                    withAttributedText:[self.attributedText attributedSubstringFromRange:range]
                                                        andSelectRange:selection];
    self.delegate = nil;
    [self.textStorage replaceCharactersInRange:range withAttributedString:text];
    self.delegate = self.superview;
    if (selection.location != NSNotFound){
        self.selectedRange = selection;
    }
}

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
                NSFontAttributeName : [FCStyle.caption toHelvetica:0],
                NSForegroundColorAttributeName : FCStyle.fcBlack
             }];
        }
        else{
            lineAttributedString = [ContentFilterHighlighter rule:line];
            [lineAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{
                NSFontAttributeName : [FCStyle.caption toHelvetica:0],
                NSForegroundColorAttributeName : FCStyle.fcBlack
             }]];
        }
        [newAttributedString appendAttributedString:lineAttributedString];
    }
    
    [self.textView replaceRange:NSMakeRange(0, self.textView.attributedText.length)
                withAttributedText:newAttributedString
                     selectedRange:NSMakeRange(0, 0)];
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
            NSFontAttributeName : [FCStyle.caption toHelvetica:0],
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
