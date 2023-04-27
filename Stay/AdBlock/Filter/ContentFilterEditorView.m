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
#import "InputMenu.h"

NSNotificationName const _Nonnull ContentFilterEditorTextDidChangeNotification = @"app.stay.notification.ContentFilterEditorTextDidChangeNotification";

static NSUInteger LineNumberWidth = 60;
static const NSAttributedStringKey CFLineNoAttributeName = @"_CFLineNoAttributeName";

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
@property (nonatomic, assign) NSUInteger base;
@property (nonatomic, assign) NSUInteger lineNo;
@end

@implementation ContentFilterLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin{
    self.lineNoSet = [[NSMutableSet alloc] init];
    [self drawNumberAtRange:glyphsToShow];
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

- (void)drawNumberAtRange:(NSRange)range{
    [self enumerateLineFragmentsForGlyphRange:range usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        CGRect correctRect  = CGRectOffset(rect, self.textContainerOriginOffset.x, self.textContainerOriginOffset.y);
        
        [FCStyle.secondaryPopup setFill];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, correctRect.origin.y, LineNumberWidth, correctRect.size.height) cornerRadius:0] fill];
       
        if (NSMaxRange(glyphRange) <= self.textStorage.length){
            NSAttributedString *line = [self.textStorage attributedSubstringFromRange:glyphRange];
            NSNumber *lineNo = [line attribute:CFLineNoAttributeName atIndex:0 effectiveRange:nil];
            
            if (lineNo && ![self.lineNoSet containsObject:lineNo]){
                //            NSInteger lineNumber = (NSInteger)(rect.origin.y / rect.size.height) + 1;
                NSString *lineNumberStr = [lineNo stringValue];
                CGRect lineNumberRect = [lineNumberStr boundingRectWithSize:CGSizeMake(LineNumberWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName : FCStyle.footnote}
                                                                    context:nil];
                
                [lineNumberStr drawAtPoint:CGPointMake(LineNumberWidth - lineNumberRect.size.width - 5, correctRect.origin.y)
                            withAttributes:@{
                    NSForegroundColorAttributeName : FCStyle.fcSecondaryBlack,
                    NSFontAttributeName : FCStyle.footnote
                }];
                [self.lineNoSet addObject:lineNo];
            }
        }
    }];
}

@end

@interface ContentFilterTextView()

@property (nonatomic, assign) BOOL textFromPaste;
@property (nonatomic, assign) NSRange textShouldChangeRange;
@property (nonatomic, copy) NSString *willTypingText;
@end

@implementation ContentFilterTextView

- (void)paste:(id)sender{
    self.textFromPaste = YES;
    [super paste:sender];
}


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

- (NSMutableAttributedString *)activateLineAttributedString:(NSRangePointer)lineRange{
    UITextPosition *cursorPosition = self.selectedTextRange.end;
    return [self _lineAttributedStringAtPosition:cursorPosition lineRange:lineRange];
}

- (NSMutableAttributedString *)_lineAttributedStringAtPosition:(UITextPosition *)position lineRange:(NSRangePointer)lineRange{
    NSInteger line = [self offsetFromPosition:self.beginningOfDocument toPosition:position];
    *lineRange = [self.text lineRangeForRange:NSMakeRange(line, 0)];
    NSMutableAttributedString *lineAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:
                                                     [self.attributedText attributedSubstringFromRange:*lineRange]];
    return lineAttributedText;
}

- (NSMutableAttributedString *)lineAttributedStringAtLocation:(NSUInteger)location lineRange:(NSRangePointer)lineRange{
    UITextPosition *end = [self positionFromPosition:self.beginningOfDocument offset:location];
    NSMutableAttributedString *lineAttributedString = [self _lineAttributedStringAtPosition:end lineRange:lineRange];
    if (location > NSMaxRange(*lineRange)){
        *lineRange = NSMakeRange(NSNotFound, 0);
        return nil;
    }
    return lineAttributedString;
}

- (NSArray<NSDictionary *> *)linesAttributedStringAtRange:(NSRange)range
                                                     linesRange:(NSRangePointer)linesRange{
    NSMutableArray<NSDictionary *> *linesInfo = [[NSMutableArray alloc] init];
    NSUInteger location = range.location;
    NSUInteger outLocation = range.location;
    NSUInteger outLength = 0;
    while(location < NSMaxRange(range)){
        NSRange lineRange;
        NSAttributedString *line = [self lineAttributedStringAtLocation:location lineRange:&lineRange];
        if (nil == line){
            break;
        }
        location = NSMaxRange(lineRange);
        outLocation = MIN(outLocation, lineRange.location);
        outLength += lineRange.length;
        [linesInfo addObject:@{
            @"text":line,
            @"range":[NSValue valueWithRange:lineRange]
        }];
    }
    *linesRange = NSMakeRange(outLocation, outLength);
    return linesInfo;
}

- (BOOL)isTypingEnter{
    return [self.willTypingText isEqualToString:@"\n"];
}


- (BOOL)isTypingDelete{
    return [self.willTypingText isEqualToString:@"\aDelete"];
}

@end

@interface ContentFilterEditorView()<
 UITextViewDelegate,
 InputMenuHosting
>
@property (nonatomic, strong) ContentFilterTextContainer *textContainer;
@property (nonatomic, strong) ContentFilterLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) InputMenu *inputMenu;
@property (nonatomic, strong) NSLayoutConstraint *textViewBottomConstraint;
@property (nonatomic, assign) NSUInteger nextLineCount;
@end

@implementation ContentFilterEditorView

- (instancetype)init{
    if (self = [super init]){
        [self textView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adjustForKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adjustForKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super removeFromSuperview];
}

- (void)setStrings:(NSString *)strings{
    if (0 == strings.length) strings = @"\n";
    [self.textView replaceRange:NSMakeRange(0, self.textView.attributedText.length)
             withAttributedText:[NSAttributedString captionText:strings]
                  selectedRange:NSMakeRange(0, 0)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableAttributedString *newAttributedString = [self replaceStringToAttributedString:strings];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView replaceRange:NSMakeRange(0, self.textView.attributedText.length)
                     withAttributedText:newAttributedString
                          selectedRange:NSMakeRange(0, 0)];
        });
        
    });
}

- (NSMutableAttributedString *)replaceStringToAttributedString:(NSString *)strings{
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] init];
    NSInteger lineCount = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    NSMutableString *line = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < strings.length; i++){
        NSString *character = [strings substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"\n"]){
            lineCount++;
            NSMutableAttributedString *lineAttributedString = [ContentFilterHighlighter rule:line];
            [lineAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{
                NSFontAttributeName : [FCStyle.caption toHelvetica:0],
                NSForegroundColorAttributeName : FCStyle.fcBlack,
                NSParagraphStyleAttributeName : paragraphStyle,
            }]];
            
            [lineAttributedString addAttributes:@{
                CFLineNoAttributeName : @(lineCount)
            } range:NSMakeRange(0, lineAttributedString.length)];
            
            [line deleteCharactersInRange:NSMakeRange(0, line.length)];
            [newAttributedString appendAttributedString:lineAttributedString];
        }
        else{
            [line appendString:character];
        }
    }
    
    return newAttributedString;
}

- (BOOL)textView:(ContentFilterTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.markedTextRange){
        UITextPosition* beginning = textView.beginningOfDocument;
        UITextPosition *markedStart = textView.markedTextRange.start;
        NSInteger location = [textView offsetFromPosition:beginning toPosition:markedStart];
        textView.textShouldChangeRange = NSMakeRange(location,text.length);
    }
    else{
        textView.textShouldChangeRange = NSMakeRange(range.location, text.length);
    }
    textView.willTypingText = text.length > 0 ? text : @"\aDelete";
    if ([textView isTypingEnter]){
        NSRange lineRange;
        NSAttributedString *lineAttributedString = [textView activateLineAttributedString:&lineRange];
        NSNumber *lineNo = [lineAttributedString attribute:CFLineNoAttributeName atIndex:0 effectiveRange:nil];
        self.nextLineCount = [lineNo integerValue];
    }
    
    return YES;
}

- (void)textViewDidChange:(ContentFilterTextView *)textView{
    if (textView.markedTextRange != nil){
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentFilterEditorTextDidChangeNotification
                                                        object:self.textView];
    
    if (textView.textFromPaste){
        NSRange linesRange;
        NSArray<NSDictionary *> *linesInfo = [textView linesAttributedStringAtRange:textView.textShouldChangeRange linesRange:&linesRange];
        NSUInteger lastLineLocation = linesRange.location;
        NSUInteger lastLineLength = 0;
        NSMutableAttributedString *newLinesAttributedString = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *lastLineAttributedString;
        NSUInteger lineCount = 0;
        for (NSDictionary *lineInfo in linesInfo){
            lineCount++;
            NSAttributedString *line = lineInfo[@"text"];
            NSRange lineRange = [lineInfo[@"range"] rangeValue];
            NSString *ruleString = line.string;
            NSMutableAttributedString *newAttributedString = [ContentFilterHighlighter rule:ruleString];
            [newAttributedString addAttributes:@{
                CFLineNoAttributeName : @(lineCount)
            } range:NSMakeRange(0, newAttributedString.length)];
            [newLinesAttributedString appendAttributedString:newAttributedString];
            lastLineAttributedString = newAttributedString;
            lastLineLocation = MIN(lastLineLocation,lineRange.location);
            lastLineLength += newAttributedString.length;
        }
        [textView replaceRange:linesRange withAttributedText:newLinesAttributedString selectedRange:NSMakeRange(NSNotFound, 0)];
    }
    else{
        NSRange activateLineRange;
        NSAttributedString *lineAttributedText = [textView activateLineAttributedString:&activateLineRange];
        NSNumber *lineNo;
        for (NSUInteger i = 0; i < lineAttributedText.length; i++){
            lineNo = [lineAttributedText attribute:CFLineNoAttributeName atIndex:i effectiveRange:nil];
            if (lineNo) break;
        }
        NSString *ruleString = lineAttributedText.string;
        
        NSMutableAttributedString *newLineAttributedString = [ContentFilterHighlighter rule:ruleString];
        if (lineNo){
            [newLineAttributedString addAttributes:@{
                CFLineNoAttributeName : lineNo
            } range:NSMakeRange(0, newLineAttributedString.length)];
        }
        
        [textView.textStorage replaceCharactersInRange:activateLineRange withAttributedString:newLineAttributedString];
        
        if ([textView isTypingEnter]
            ||[textView isTypingDelete]){
            NSMutableAttributedString *newAttributedString = [self replaceStringToAttributedString:self.textView.attributedText.string];
            
            [textView.textStorage replaceCharactersInRange:NSMakeRange(0, newAttributedString.length) withAttributedString:newAttributedString];
        }
    }
}

- (NSString *)strings{
    return self.textView.attributedText.string;
}

- (void)setEditable:(BOOL)editable{
    _editable = editable;
    self.textView.editable = editable;
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
        self.textViewBottomConstraint = [_textView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0];
        [self.textViewBottomConstraint setActive:YES];
    }
    
    return _textView;
}

- (void)clearStyles{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    self.textView.typingAttributes = @{
        NSForegroundColorAttributeName : FCStyle.fcBlack,
        NSFontAttributeName : [FCStyle.caption toHelvetica:0],
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self.inputMenu show];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self.inputMenu dismiss];
}

- (InputMenu *)inputMenu{
#ifdef FC_MAC
        return nil;
#else
        if (nil == _inputMenu){
            _inputMenu = [[InputMenu alloc] init];
            _inputMenu.hosting = self;
        }
        
        return _inputMenu;
#endif
}

- (BOOL)canUndo{
    return [self.textView.undoManager canUndo];
}

- (BOOL)canRedo{
    return [self.textView.undoManager canRedo];
}

- (BOOL)canClear{
    return self.textView.attributedText.length > 0;
}

- (void)resignFirstResponder{
    [self.textView resignFirstResponder];
}

- (void)undo{
    [self.textView.undoManager undo];
}
- (void)redo{
    [self.textView.undoManager redo];
}

- (void)clear{
    [self.textView.textStorage replaceCharactersInRange:NSMakeRange(0, self.textView.attributedText.length)
                                   withAttributedString:[[NSAttributedString alloc] init]];
    [self clearStyles];
}

- (void)adjustForKeyboard:(NSNotification *)note{
    NSDictionary *info = [note userInfo];
    CGRect endRect  = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([note.name isEqualToString:UIKeyboardWillShowNotification]){
        self.textViewBottomConstraint.constant = - 35 - endRect.size.height;
        
    }
    else if ([note.name isEqualToString:UIKeyboardWillHideNotification]){
        self.textViewBottomConstraint.constant = 0;

    }
}

@end
