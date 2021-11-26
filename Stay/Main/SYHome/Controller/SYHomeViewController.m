//
//  SYHomeViewController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "SYHomeViewController.h"
#import "JSDetailCell.h"
#import "DataManager.h"

@interface SYHomeViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate,UISearchControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftIcon;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
// 数据源数组
@property (nonatomic, strong) NSMutableArray *datas;
// 搜索结果数组
@property (nonatomic, strong) NSMutableArray *results;



@end

@implementation SYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self leftIcon];
    self.view.backgroundColor = [UIColor whiteColor];
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
    search.searchResultsUpdater = self;
    search.searchBar.placeholder = @"Added user scripts";
    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = search.searchBar;
   
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
    [self initScrpitContent];
    // Do any additional setup after loading the view.
}

- (void)initScrpitContent{
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    
    for(int i = 0; i < self.datas.count; i++) {
        UserScript *scrpit = self.datas[i];
        [array addObject: [scrpit toDictionary]];
    }
    [groupUserDefaults setObject:array forKey:@"ACTIVE_SCRIPTS"];
    [groupUserDefaults synchronize];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIBarButtonItem *)leftIcon{
    if (nil == _leftIcon){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftIcon = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    }
    return _leftIcon;
}
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
//    NSString *inputStr = searchController.searchBar.text;
//    searchController.searchBar.showsCancelButton = YES;
        

    return;
}



#pragma mark -searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    [self.tableView reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    [self.tableView reloadData];
   return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    return YES;
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.results.count ;
    }
    
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[JSDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    // 这里通过searchController的active属性来区分展示数据源是哪个
    if (self.searchController.active ) {
    } else {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, kScreenWidth, 21)];
        titleLabel.font = [UIFont systemFontOfSize:21];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        UserScript *model = _datas[indexPath.row];
        titleLabel.text = model.name;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, kScreenWidth, 19)];
        authorLabel.font = [UIFont systemFontOfSize:19];
        authorLabel.textAlignment = NSTextAlignmentLeft;
        authorLabel.text = model.author;
        authorLabel.top = titleLabel.bottom + 15;
        [cell.contentView addSubview:authorLabel];
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, kScreenWidth, 19)];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.textAlignment = NSTextAlignmentLeft;
        descLabel.text = model.desc;
        descLabel.top = authorLabel.bottom + 5;
        descLabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:descLabel];
        
        UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, kScreenWidth, 24)];
        statusLabel.font = [UIFont systemFontOfSize:13];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.textColor = [UIColor whiteColor];

        if(model.active == 1) {
            statusLabel.backgroundColor = [UIColor redColor];
            statusLabel.layer.cornerRadius = 2;
            statusLabel.text = @"Stopped";
            statusLabel.width = 72;
//            [statusLabel sizeToFit];
        } else {
            statusLabel.backgroundColor = [UIColor colorWithRed:92.0/255 green:179.0/255 blue:0 alpha:1];
            statusLabel.layer.cornerRadius = 2;
            statusLabel.text = @"Activice";
            statusLabel.width = 66;
        }
        statusLabel.top = 0;
        statusLabel.right = kScreenWidth - 10;
        [cell.contentView addSubview:statusLabel];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10,99,kScreenWidth-20,1)];
        [line setBackgroundColor:RGB(138, 138, 138)];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (self.searchController.active) {
//        NSLog(@"选择了搜索结果中的%@", [self.results objectAtIndex:indexPath.row]);
//    } else {
//
//        NSLog(@"选择了列表中的%@", [self.datas objectAtIndex:indexPath.row]);
//    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        UserScript *model = _datas[indexPath.row];

        [[DataManager shareManager] updateScrpitStatus:2 numberId:model.uuid];
        [tableView setEditing:NO animated:YES];
        [self reloadTableView];
        [tableView reloadData];
    }];
    deleteAction.image = [UIImage imageNamed:@"delete"];
    deleteAction.backgroundColor = RGB(206, 55, 46);


    
    UIContextualAction *stopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        UserScript *model = _datas[indexPath.row];
        if (model.active == 1) {
            [[DataManager shareManager] updateScrpitStatus:0 numberId:model.uuid];
        } else if (model.active == 0) {
            [[DataManager shareManager] updateScrpitStatus:1 numberId:model.uuid];
        }
          [tableView setEditing:NO animated:YES];
          [self reloadTableView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
    UserScript *model = _datas[indexPath.row];
    if (model.active == 0) {
        stopAction.image = [UIImage imageNamed:@"stop"];
        stopAction.backgroundColor = RGB(208, 86, 81);
    } else {
        stopAction.image = [UIImage imageNamed:@"play"];
        stopAction.backgroundColor = RGB(92,179,0);
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,stopAction]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



- (void) reloadTableView {
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _datas;
}

- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _results;
}

@end
