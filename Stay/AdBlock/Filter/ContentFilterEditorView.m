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
#import "NSAttributedString+Style.h"

static NSUInteger LineNumberWidth = 50;

@interface ContentFilterTextContainer : NSTextContainer

@end

@implementation ContentFilterTextContainer

- (instancetype)init{
    if (self = [super init]){
        self.heightTracksTextView = YES;
        self.widthTracksTextView = YES;
    }
    
    return self;
}

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect{
    CGRect originRect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];
    
    return CGRectMake(originRect.origin.x + LineNumberWidth, originRect.origin.y, originRect.size.width - LineNumberWidth, originRect.size.height);
}

@end

@interface ContentFilterLayoutManager : NSLayoutManager
@property (nonatomic, assign) CGPoint textContainerOriginOffset;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *lineNoSet;
@end

@implementation ContentFilterLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin{
    NSUInteger characterIndex = glyphsToShow.location;
    NSUInteger glyphIndex = [self glyphIndexForCharacterAtIndex:characterIndex];
//    if (![self.lineNoSet containsObject:@(glyphIndex)]){
//        [self drawNumber:glyphIndex ange:glyphsToShow];
//        [self.lineNoSet addObject:@(glyphIndex)];
//    }
    [self drawNumber:glyphIndex ange:glyphsToShow];
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

- (NSMutableSet<NSNumber *> *)lineNoSet{
    if (nil == _lineNoSet){
        _lineNoSet = [[NSMutableSet alloc] init];
    }
    
    return _lineNoSet;
}

- (void)drawNumber:(NSUInteger)number ange:(NSRange)range{
    NSRange effectiveRange;
    CGRect lineRect = [self lineFragmentRectForGlyphAtIndex:range.location effectiveRange:&effectiveRange];
    CGRect correctRect = CGRectOffset(lineRect, self.textContainerOriginOffset.x, self.textContainerOriginOffset.y);
    
    [FCStyle.secondaryPopup setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, correctRect.origin.y, LineNumberWidth, correctRect.size.height) cornerRadius:0] fill];
    
//    [[NSString stringWithFormat:@"%ld",number] drawInRect:correctRect withAttributes:@{
//        NSForegroundColorAttributeName : FCStyle.fcSecondaryBlack
//    }];
}

@end

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
@property (nonatomic, strong) ContentFilterTextContainer *textContainer;
@property (nonatomic, strong) ContentFilterLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextStorage *textStorage;
@end

@implementation ContentFilterEditorView

- (instancetype)init{
    if (self = [super init]){
        [self textView];
    }
    
    return self;
}

- (void)setStrings:(NSString *)strings{
    [self.textView replaceRange:NSMakeRange(0, self.textView.attributedText.length)
                withAttributedText:[NSAttributedString captionText:strings]
                     selectedRange:NSMakeRange(0, 0)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] init];
        NSArray<NSString *> *lines = [strings componentsSeparatedByString:@"\n"];
        NSInteger lineCount = 0;
        for (NSString *line in lines){
            lineCount++;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView replaceRange:NSMakeRange(0, self.textView.attributedText.length)
                        withAttributedText:newAttributedString
                             selectedRange:NSMakeRange(0, 0)];
        });
        
    });
    
    
    
    
}

- (ContentFilterTextView *)textView{
    if (nil == _textView){
        self.textStorage = [[NSTextStorage alloc] init];
        self.layoutManager = [[ContentFilterLayoutManager alloc] init];
        self.textContainer = [[ContentFilterTextContainer alloc] init];
        [self.layoutManager addTextContainer:self.textContainer];
        [self.textStorage addLayoutManager:self.layoutManager];
        _textView = [[ContentFilterTextView alloc] initWithFrame:CGRectZero textContainer:self.textContainer];
        self.layoutManager.textContainerOriginOffset = CGPointMake(_textView.textContainerInset.left, _textView.textContainerInset.top);
        _textView.delegate = self;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textView.showsVerticalScrollIndicator = YES;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        _textView.typingAttributes = @{
            NSForegroundColorAttributeName : FCStyle.fcBlack,
            NSFontAttributeName : [FCStyle.caption toHelvetica:0],
            NSParagraphStyleAttributeName : paragraphStyle,
//            NSKernAttributeName : @(0.5)
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
