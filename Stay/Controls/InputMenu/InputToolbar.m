//
//  InputToolbar.m
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "InputToolbar.h"
#import "QuickAccess.h"
#import "FCApp.h"
#import "InputToolbarItem.h"
#import "FCStyle.h"
#import "InputToolbarItemSeperator.h"
#import "InputMenu.h"
#import "ContentFilterEditorView.h"

static NSString *InputToolbarCellIdentifier = @"InputToolbarCellIdentifier";

@interface InputToolbar()<
 UICollectionViewDelegate,
 UICollectionViewDataSource
>

@property (nonatomic, strong) NSArray<InputToolbarItemElement *> *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *fixedRightView;
@property (nonatomic, strong) InputToolbarItem *keyboardItem;
@property (nonatomic, strong) UIView *line;
@end

@implementation InputToolbar

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.hideNavigationBar = YES;
    self.view.backgroundColor = [UIColor clearColor];
    [self collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:InputToolbarCellIdentifier];
    
    [self fixedRightView];
    [self keyboardItem];
    [self line];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentFilterEditorDidChange:) name:ContentFilterEditorTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    
}

- (void)contentFilterEditorDidChange:(NSNotification *)note{
    InputMenu *inputMenu = (InputMenu *)self.navigationController.slideController;
    self.dataSource[2].enabled = [inputMenu.hosting canClear];
    [self.collectionView reloadData];
}


- (NSArray<InputToolbarItemElement *> *)dataSource{
    if (nil == _dataSource){
        InputMenu *inputMenu = (InputMenu *)self.navigationController.slideController;
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        InputToolbarItemElement *undoElement = [[InputToolbarItemElement alloc] init];
        undoElement.imageName = @"arrow.uturn.backward";
        undoElement.imageFont = FCStyle.secondaryCellIcon;
        undoElement.enabled = [inputMenu.hosting canUndo];
        __weak InputToolbar *weakSelf = self;
        undoElement.action = ^(InputToolbarItem * _Nonnull item) {
            if (item.element.enabled){
                [inputMenu.hosting undo];
                item.element.enabled = [inputMenu.hosting canUndo];
                [weakSelf.collectionView reloadData];
            }
        };
        [temp addObject:undoElement];
        
        InputToolbarItemElement *redoElement = [[InputToolbarItemElement alloc] init];
        redoElement.imageName = @"arrow.uturn.forward";
        redoElement.imageFont = FCStyle.secondaryCellIcon;
        redoElement.enabled = [inputMenu.hosting canRedo];
        redoElement.action = ^(InputToolbarItem * _Nonnull item) {
            if (item.element.enabled){
                [inputMenu.hosting redo];
                item.element.enabled = [inputMenu.hosting canRedo];
                [weakSelf.collectionView reloadData];
            }
        };
        [temp addObject:redoElement];
        
        InputToolbarItemElement *clearElement = [[InputToolbarItemElement alloc] init];
        clearElement.imageName = @"clear";
        clearElement.enabled = [inputMenu.hosting canClear];
        clearElement.imageDeltaY = 5;
        clearElement.action = ^(InputToolbarItem * _Nonnull item) {
            if (item.element.enabled){
                [inputMenu.hosting clear];
                item.element.enabled = [inputMenu.hosting canClear];
                [weakSelf.collectionView reloadData];
            }
        };
        [temp addObject:clearElement];
        
//        InputToolbarItemElement *seperator = [[InputToolbarItemElement alloc] init];
//        seperator.isSeperator = YES;
//        [temp addObject:seperator];
        
        _dataSource = temp;
    }
    
    return _dataSource;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:InputToolbarCellIdentifier forIndexPath:indexPath];
    if (cell.contentView.subviews.count > 0){
        [cell.contentView.subviews[0] removeFromSuperview];
    }
    InputToolbarItemElement *element = self.dataSource[indexPath.row];
    if (element.isSeperator){
        InputToolbarItemSeperator *seperatorView = [[InputToolbarItemSeperator alloc] initWithElement:element];
        [cell.contentView addSubview:seperatorView];
    }
    else{
        InputToolbarItem *itemView = [[InputToolbarItem alloc] initWithElement:element];
        [cell.contentView addSubview:itemView];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    InputToolbarItemElement *element = self.dataSource[indexPath.row];
    if (element.isSeperator){
        return CGSizeMake(1, 26);
    }
    else{
        return CGSizeMake(35, 26);
    }
}
    

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 5, 0, 0);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}


- (UIView *)fixedRightView{
#ifdef FC_IOS
    if (nil == _fixedRightView){
        _fixedRightView = [[UIView alloc] init];
        _fixedRightView.layer.cornerRadius = 10;
        _fixedRightView.layer.shouldRasterize = YES;
        _fixedRightView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _fixedRightView.backgroundColor = FCStyle.popup;
        _fixedRightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_fixedRightView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_fixedRightView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_fixedRightView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_fixedRightView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [_fixedRightView.widthAnchor constraintEqualToConstant:35+10]
        ]];
        
        _fixedRightView.layer.shadowOpacity = 0;
        _fixedRightView.layer.shadowOffset = CGSizeMake(-1, 0);
        _fixedRightView.layer.shadowRadius = 5;
        _fixedRightView.layer.shadowColor = FCStyle.fcSeparator.CGColor;
        _fixedRightView.layer.shadowPath = [self fixedRightShadowPath:CGRectMake(0, 0, 35, 35)].CGPath;
       
    }
    
    return _fixedRightView;
#else
    return nil;
#endif
}

- (InputToolbarItem *)keyboardItem{
#ifdef FC_IOS
    if (nil == _keyboardItem){
        InputMenu *inputMenu = (InputMenu *)self.navigationController.slideController;
        InputToolbarItemElement *element = [[InputToolbarItemElement alloc] init];
        element.imageName = @"keyboard.chevron.compact.down";
        element.imageFont = FCStyle.secondaryCellIcon;
        element.action = ^(InputToolbarItem * _Nonnull item) {
            if (item.element.enabled){
                [inputMenu.hosting resignFirstResponder];
            }
        };
        
        _keyboardItem = [[InputToolbarItem alloc] initWithElement:element];
        _keyboardItem.fillSuperView = NO;
        [self.fixedRightView addSubview:_keyboardItem];
        
        [NSLayoutConstraint activateConstraints:@[
            [_keyboardItem.widthAnchor constraintEqualToConstant:35],
            [_keyboardItem.heightAnchor constraintEqualToConstant:26],
            [_keyboardItem.topAnchor constraintEqualToAnchor:self.fixedRightView.topAnchor constant:4.5],
            [_keyboardItem.leadingAnchor constraintEqualToAnchor:self.fixedRightView.leadingAnchor constant:5]
        ]];
    }
    
    return _keyboardItem;
#else
    return nil;
#endif
}

- (UIBezierPath *)fixedRightShadowPath:(CGRect)rect{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat minX = rect.origin.x;
    CGFloat minY = rect.origin.y;
    CGFloat maxY = rect.origin.y + rect.size.height;
    CGFloat radius = 10 * 2;
    
    [path moveToPoint:CGPointMake(minX + radius, minY)];
    [path addQuadCurveToPoint:CGPointMake(minX, minY + radius) controlPoint:CGPointMake(minX, minY)];
    [path addLineToPoint:CGPointMake(minX, maxY - radius)];
    [path addQuadCurveToPoint:CGPointMake(minX + radius, maxY) controlPoint:CGPointMake(minX, maxY)];
    return path;
}

- (UIView *)line{
#ifdef FC_IOS
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        _line.backgroundColor = FCStyle.fcSeparator;
        [self.view addSubview:_line];
        [NSLayoutConstraint activateConstraints:@[
            [_line.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_line.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_line.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_line.heightAnchor constraintEqualToConstant:0.5]
        ]];
    }
    
    return _line;
#else
    return nil;
#endif
}

- (UICollectionView *)collectionView{
    if (nil == _collectionView){
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 5;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
        [NSLayoutConstraint activateConstraints:@[
            [_collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
#ifdef FC_IOS
            [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-35-10],
#else
            [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
#endif
            
            [_collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:2],
            [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-2],
        ]];
    }
    
    return _collectionView;
}

- (CGSize)mainViewSize{
#ifdef FC_MAC
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 60, 450 - 60) , 35);
#else
    CGSize size = [QuickAccess secondarySize];
    if (CGSizeEqualToSize(size, CGSizeZero)){
        return CGSizeMake(FCApp.keyWindow.frame.size.width, 35);
    }
    else{
        return CGSizeMake([QuickAccess secondarySize].width, 35);
    }
    
#endif
}


@end
