//
//  ImportMenuModalViewController.m
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import "ImportMenuModalViewController.h"
#import "FCStyle.h"

@interface _MenuButton : UIView

- (void)setTitle:(NSString *)title;
- (void)setSFSymbol:(NSString *)sfName;
- (void)addTarget:(id)target action:(SEL)selector;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@implementation _MenuButton
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = FCStyle.secondaryPopup;
        self.layer.cornerRadius = 10;
        [self titleLabel];
        [self iconImageView];
    }
    
    return self;
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 18)/2, 200, 18)];
        _titleLabel.font = FCStyle.body;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIImageView *)iconImageView{
    if (nil == _iconImageView){
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - 23,(self.frame.size.height - 23)/2,23,23)];
        [self addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (void)setSFSymbol:(NSString *)sfName{
    UIImage *image = [UIImage systemImageNamed:sfName
                             withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]];
    image = [image imageWithTintColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
    self.iconImageView.image = image;
}

- (void)addTarget:(id)target action:(SEL)selector{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGesture];
}

@end

@interface ImportMenuModalViewController()

@property (nonatomic, strong) _MenuButton *writeButton;
@property (nonatomic, strong) _MenuButton *linkButton;
@property (nonatomic, strong) _MenuButton *greasyForkButton;
@property (nonatomic, strong) _MenuButton *fileButton;
@end

@implementation ImportMenuModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self writeButton];
    [self linkButton];
    [self greasyForkButton];
    [self fileButton];
}

- (_MenuButton *)writeButton{
    if (nil == _writeButton){
        _writeButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 45)];
        [_writeButton setTitle:NSLocalizedString(@"settings.addScript", @"")];
        [_writeButton setSFSymbol:@"pencil.circle.fill"];
        [_writeButton addTarget:self action:@selector(writeAction)];
        [self.view addSubview:_writeButton];
    }
    return _writeButton;
}

- (_MenuButton *)linkButton{
    if (nil == _linkButton){
        _linkButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.writeButton.bottom + 15, self.view.frame.size.width - 30, 45)];
        [_linkButton setTitle:NSLocalizedString(@"settings.addScriptFromUrl", @"")];
        [_linkButton setSFSymbol:@"link.circle.fill"];
        [_linkButton addTarget:self action:@selector(linkAction)];
        [self.view addSubview:_linkButton];
    }
    return _linkButton;
}

- (_MenuButton *)greasyForkButton{
    if (nil == _greasyForkButton){
        _greasyForkButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.linkButton.bottom + 15, self.view.frame.size.width - 30, 45)];
        [_greasyForkButton setTitle:NSLocalizedString(@"settings.addScriptFromWeb", @"")];
        [_greasyForkButton setSFSymbol:@"g.circle.fill"];
        [_greasyForkButton addTarget:self action:@selector(greasyForkAction)];
        [self.view addSubview:_greasyForkButton];
    }
    return _greasyForkButton;
}

- (_MenuButton *)fileButton{
    if (nil == _fileButton){
        _fileButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.greasyForkButton.bottom + 15, self.view.frame.size.width - 30, 45)];
        [_fileButton setTitle:NSLocalizedString(@"settings.importFromFile", @"")];
        [_fileButton setSFSymbol:@"doc.circle.fill"];
        [_fileButton addTarget:self action:@selector(fileAction)];
        [self.view addSubview:_fileButton];
    }
    return _fileButton;
}

- (void)writeAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addScriptClick" object:@(0)];
}

- (void)linkAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addScriptClick" object:@(1)];
}

- (void)greasyForkAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addScriptClick" object:@(2)];
}

- (void)fileAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addScriptClick" object:@(3)];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(kScreenWidth - 30, 450), 255);
}

@end
