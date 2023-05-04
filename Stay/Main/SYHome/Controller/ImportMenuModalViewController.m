//
//  ImportMenuModalViewController.m
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import "ImportMenuModalViewController.h"
#import "FCStyle.h"

@interface _MenuButton : UIView

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;
- (void)setSFSymbol:(NSString *)sfName;
- (void)setImageByName:(NSString *)name;

- (void)addTarget:(id)target action:(SEL)selector;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@implementation _MenuButton
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = FCStyle.secondaryPopup;
        self.layer.cornerRadius = 10;
        [self iconImageView];
        [self titleLabel];
        [self subTitleLabel];
    }
    
    return self;
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FCStyle.bodyBold;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_titleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.heightAnchor constraintEqualToConstant:19],
            [_titleLabel.leftAnchor constraintEqualToAnchor:self.iconImageView.rightAnchor constant:12],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:13]
        ]];
    }
    
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (nil == _subTitleLabel){
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = FCStyle.footnote;
        _subTitleLabel.textColor = FCStyle.subtitleColor;
        _subTitleLabel.userInteractionEnabled = NO;
        _subTitleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_subTitleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_subTitleLabel.heightAnchor constraintEqualToConstant:20],
            [_subTitleLabel.leftAnchor constraintEqualToAnchor:self.iconImageView.rightAnchor constant:12],
            [_subTitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:4]
        ]];
    }
    
    return _subTitleLabel;
}

- (UIImageView *)iconImageView{
    if (nil == _iconImageView){
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_iconImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.widthAnchor constraintEqualToConstant:30],
            [_iconImageView.heightAnchor constraintEqualToConstant:30],
            [_iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
            [_iconImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:21]
        ]];
        
    }
    
    return _iconImageView;
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle{
    self.titleLabel.text = title;
    self.subTitleLabel.text = subTitle;
}

- (void)setSFSymbol:(NSString *)sfName{
    UIImage *image = [UIImage systemImageNamed:sfName
                             withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]];
    image = [image imageWithTintColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
    self.iconImageView.image = image;
}

- (void)setImageByName:(NSString *)name {
    
    
//    [UIImage imageNamed:@"GreasyforkIcon" inBundle:<#(nullable NSBundle *)#> withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]]]
    UIImage *image = [UIImage imageNamed:name];
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
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ImportMenuModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self titleLabel];
    [self writeButton];
    [self linkButton];
    [self greasyForkButton];
    [self fileButton];
}

- (UILabel *)titleLabel {
    if(nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 23, 200, 21)];
        _titleLabel.font = FCStyle.headlineBold;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.text = NSLocalizedString(@"settings.addScriptTitle", @"");
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (_MenuButton *)writeButton{
    if (nil == _writeButton){
        _writeButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, 62, self.view.frame.size.width - 30, 70)];
        [_writeButton setTitle:NSLocalizedString(@"settings.addScript", @"") subTitle:NSLocalizedString(@"settings.addScriptDesc", @"")];
        [_writeButton setSFSymbol:@"doc.badge.plus"];
        [_writeButton addTarget:self action:@selector(writeAction)];
        [self.view addSubview:_writeButton];
    }
    return _writeButton;
}

- (_MenuButton *)linkButton{
    if (nil == _linkButton){
        _linkButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.writeButton.bottom + 15, self.view.frame.size.width - 30, 70)];
        [_linkButton setTitle:NSLocalizedString(@"settings.addScriptFromUrl", @"") subTitle:NSLocalizedString(@"settings.addScriptFromUrlDesc", @"")];
        [_linkButton setSFSymbol:@"link"];
        [_linkButton addTarget:self action:@selector(linkAction)];
        [self.view addSubview:_linkButton];
    }
    return _linkButton;
}

- (_MenuButton *)greasyForkButton{
    if (nil == _greasyForkButton){
        _greasyForkButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.linkButton.bottom + 15, self.view.frame.size.width - 30, 70)];
        [_greasyForkButton setTitle:NSLocalizedString(@"settings.addScriptFromWeb", @"") subTitle:NSLocalizedString(@"settings.addScriptFromWebDesc", @"")];
        [_greasyForkButton setImageByName:@"GreasyforkIcon"];
        [_greasyForkButton addTarget:self action:@selector(greasyForkAction)];
        [self.view addSubview:_greasyForkButton];
    }
    return _greasyForkButton;
}

- (_MenuButton *)fileButton{
    if (nil == _fileButton){
        _fileButton = [[_MenuButton alloc] initWithFrame:CGRectMake(15, self.greasyForkButton.bottom + 15, self.view.frame.size.width - 30, 70)];
        [_fileButton setTitle:NSLocalizedString(@"settings.importFromFile", @"") subTitle:NSLocalizedString(@"settings.importFromFileDesc", @"") ];
        [_fileButton setSFSymbol:@"folder"];
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
    return CGSizeMake(MIN(kScreenWidth - 30, 450), 410);
}

@end
