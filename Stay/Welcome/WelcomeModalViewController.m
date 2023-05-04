//
//  WelcomeModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/1.
//

#import "WelcomeModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ModalSectionElement.h"
#import "ModalItemElement.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"

@interface WelcomeModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UILabel *stayLabel;
@property (nonatomic, strong) UILabel *developedLabel1;
@property (nonatomic, strong) UIImageView *djImageView;
@property (nonatomic, strong) UILabel *developedLabel2;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *enableStayElemnt;
@property (nonatomic, strong) ModalItemElement *installUserscriptElement;
@property (nonatomic, strong) ModalItemElement *doneElement;
@end

@implementation WelcomeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = NO;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.showCancel = NO;
    
    [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    [self welcomeLabel];
    [self stayLabel];
    [self developedLabel2];
    [self djImageView];
    [self developedLabel1];
    [self tableView];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    cell.backgroundColor = UIColor.clearColor;
    ModalItemView *modalItemView = [ModalItemViewFactory ofElement:element];
    modalItemView.backgroundColor = UIColor.clearColor;
    [cell.contentView addSubview:modalItemView];
    modalItemView.cell = cell;
    [modalItemView attachGesture];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ModalSectionElement *element = self.dataSource[section][@"sectionElement"];
    ModalSectionView *sectionView = [[ModalSectionView alloc] initWithElement:element];
    sectionView.backgroundColor = UIColor.clearColor;
    sectionView.contentView.backgroundColor = UIColor.clearColor;
    return sectionView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"itemElements"]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    CGFloat contentHeight = [element contentHeightWithWidth:self.view.width];
    return contentHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.view.bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [self.view.layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}

- (UILabel *)welcomeLabel{
    if (nil == _welcomeLabel){
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _welcomeLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"WelcomeTo", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.accent,
            NSFontAttributeName: [UIFont boldSystemFontOfSize:60],
            NSKernAttributeName : @(0.5)
            
        }];
        _welcomeLabel.backgroundColor = UIColor.clearColor;
        _welcomeLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_welcomeLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_welcomeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_welcomeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_welcomeLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:60],
        ]];
    }
    
    return _welcomeLabel;
}

- (UILabel *)stayLabel{
    if (nil == _stayLabel){
        _stayLabel = [[UILabel alloc] init];
        _stayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _stayLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stay", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.accent,
            NSFontAttributeName: [UIFont boldSystemFontOfSize:60],
            NSKernAttributeName : @(0.5)
            
        }];
        _stayLabel.backgroundColor = UIColor.clearColor;
        _stayLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_stayLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_stayLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_stayLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_stayLabel.topAnchor constraintEqualToAnchor:self.welcomeLabel.bottomAnchor]
        ]];
    }
    
    return _stayLabel;
}

- (UILabel *)developedLabel2{
    if (nil == _developedLabel2){
        _developedLabel2 = [[UILabel alloc] init];
        _developedLabel2.translatesAutoresizingMaskIntoConstraints = NO;
        _developedLabel2.text = @"APPS";
        _developedLabel2.textColor = FCStyle.fcSecondaryBlack;
        _developedLabel2.font = FCStyle.footnoteBold;
        [self.view addSubview:_developedLabel2];
        [NSLayoutConstraint activateConstraints:@[
            [_developedLabel2.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_developedLabel2.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _developedLabel2;
}

- (UIImageView *)djImageView{
    if (nil == _djImageView){
        _djImageView = [[UIImageView alloc] init];
        _djImageView.image = [UIImage imageNamed:@"DJIcon"];
        _djImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_djImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_djImageView.trailingAnchor constraintEqualToAnchor:self.developedLabel2.leadingAnchor constant:-5],
            [_djImageView.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _djImageView;
}

- (UILabel *)developedLabel1{
    if (nil == _developedLabel1){
        _developedLabel1 = [[UILabel alloc] init];
        _developedLabel1.translatesAutoresizingMaskIntoConstraints = NO;
        _developedLabel1.text = @"Developed by";
        _developedLabel1.textColor = FCStyle.fcSecondaryBlack;
        _developedLabel1.font = FCStyle.footnoteBold;
        [self.view addSubview:_developedLabel1];
        [NSLayoutConstraint activateConstraints:@[
            [_developedLabel1.trailingAnchor constraintEqualToAnchor:self.djImageView.leadingAnchor constant:-5],
            [_developedLabel1.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _developedLabel1;
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = UIColor.clearColor;
        [self.view addSubview:_tableView];
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-5],
            [_tableView.topAnchor constraintEqualToAnchor:self.developedLabel1.bottomAnchor constant:30],
            [_tableView.heightAnchor constraintEqualToConstant:15 * self.dataSource.count + 45 * 3]
        ]];
    }
    
    return _tableView;
}

- (NSArray<NSDictionary *> *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.enableStayElemnt]
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.installUserscriptElement]
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.doneElement]
            }
        ];
    }
    
    return _dataSource;
}

- (ModalItemElement *)enableStayElemnt{
    if (nil == _enableStayElemnt){
        _enableStayElemnt = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"EnableStayStep1", @"");
        general.titleFont = FCStyle.headlineBold;
        general.accessoryFont = FCStyle.sfSecondaryIconBold;
        _enableStayElemnt.generalEntity = general;
        _enableStayElemnt.renderMode = ModalItemElementRenderModeSingle;
        _enableStayElemnt.type = ModalItemElementTypeAccessory;
    }
    
    return _enableStayElemnt;
}

- (ModalItemElement *)installUserscriptElement{
    if (nil == _installUserscriptElement){
        _installUserscriptElement = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"InstallUserscriptStep2", @"");
        _installUserscriptElement.generalEntity = general;
        _installUserscriptElement.renderMode = ModalItemElementRenderModeSingle;
        _installUserscriptElement.type = ModalItemElementTypeAccessory;
    }
    
    return _installUserscriptElement;
}

- (ModalItemElement *)doneElement{
    if (nil == _doneElement){
        _doneElement = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"DoneStep3", @"");
        _doneElement.generalEntity = general;
        _doneElement.renderMode = ModalItemElementRenderModeSingle;
        _doneElement.type = ModalItemElementTypeAccessory;
    }
    
    return _doneElement;
}

- (CGSize)mainViewSize{
    return FCApp.keyWindow.size;
}

@end
