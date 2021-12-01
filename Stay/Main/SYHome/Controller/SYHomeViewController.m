//
//  SYHomeViewController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "SYHomeViewController.h"
#import "JSDetailCell.h"
#import "DataManager.h"
#import "SYDetailViewController.h"

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
    search.searchBar.placeholder = @"Search Added user scripts";
    self.searchController = search;
    self.searchController.delegate = self;
//    self.searchController.searchBar.delegate = self;
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
    self.searchController.searchBar.showsScopeBar = false;
//    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    [self.tableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    [self.tableView reloadData];
//    self.searchController.searchBar.showsCancelButton = true;
    for (UIView *view in [[ self.searchController.searchBar.subviews lastObject] subviews]) {
          if ([view isKindOfClass:[UIButton class]]) {
              UIButton *cancelBtn = (UIButton *)view;
              [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
              [cancelBtn setTitleColor:RGB(182, 32, 224) forState:UIControlStateNormal];
          }

      }
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_results removeAllObjects];
    if(searchText.length > 0) {
        [_results addObjectsFromArray:[[DataManager shareManager] selectScriptByKeywordByAdded:searchText]];
    }
    [self.tableView reloadData];

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
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    // 这里通过searchController的active属性来区分展示数据源是哪个
    if (self.searchController.active ) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, kScreenWidth, 21)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        UserScript *model = _results[indexPath.row];
        titleLabel.text = model.name;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth, 19)];
        authorLabel.font = [UIFont systemFontOfSize:16];
        authorLabel.textAlignment = NSTextAlignmentLeft;
        authorLabel.text = model.author;
        authorLabel.top = titleLabel.bottom + 10;
        [authorLabel sizeToFit];
        [cell.contentView addSubview:authorLabel];
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth, 19)];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.textAlignment = NSTextAlignmentLeft;
        descLabel.text = model.desc;
        descLabel.top = authorLabel.bottom + 5;
        descLabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:descLabel];
        
        UILabel *actLabel = [[UILabel alloc]init];
        actLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        actLabel.textColor = RGB(138, 138, 138);
        if(model.active == 0) {
            actLabel.text = @"Stopped";
        } else {
            actLabel.text = @"Actived";
        }
        [actLabel sizeToFit];
        actLabel.right = kScreenWidth - 35;
        actLabel.centerY = 47.5f;

        [cell.contentView addSubview:actLabel];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,94,kScreenWidth-10,1)];
        [line setBackgroundColor:RGB(216, 216, 216)];
        [cell.contentView addSubview:line];
    } else {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, kScreenWidth, 21)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        UserScript *model = _datas[indexPath.row];
        titleLabel.text = model.name;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth, 19)];
        authorLabel.font = [UIFont systemFontOfSize:16];
        authorLabel.textAlignment = NSTextAlignmentLeft;
        authorLabel.text = model.author;
        authorLabel.top = titleLabel.bottom + 10;
        [authorLabel sizeToFit];
        [cell.contentView addSubview:authorLabel];
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth, 19)];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.textAlignment = NSTextAlignmentLeft;
        descLabel.text = model.desc;
        descLabel.top = authorLabel.bottom + 5;
        descLabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:descLabel];
        
        UILabel *actLabel = [[UILabel alloc]init];
        actLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        actLabel.textColor = RGB(138, 138, 138);
        if(model.active == 0) {
            actLabel.text = @"Stopped";
        } else {
            actLabel.text = @"Actived";
        }
        [actLabel sizeToFit];
        actLabel.right = kScreenWidth - 35;
        actLabel.centerY = 47.5f;

        [cell.contentView addSubview:actLabel];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,94,kScreenWidth - 10,1)];
        [line setBackgroundColor:RGBA(216, 216, 216, 0.3)];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchController.active) {
        UserScript *model = _results[indexPath.row];
        SYDetailViewController *cer = [[SYDetailViewController alloc] init];
        cer.script = model;
        self.navigationController.navigationBar.tintColor = RGB(182, 32, 224);
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(182, 32, 224)}];
        [self.navigationController pushViewController:cer animated:true];
    } else {
        UserScript *model = _datas[indexPath.row];
        SYDetailViewController *cer = [[SYDetailViewController alloc] init];
        cer.script = model;
        self.navigationController.navigationBar.tintColor = RGB(182, 32, 224);
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(182, 32, 224)}];
        [self.navigationController pushViewController:cer animated:true];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = _results[indexPath.row];

            [[DataManager shareManager] updateScrpitStatus:2 numberId:model.uuid];
            [tableView setEditing:NO animated:YES];
            [self reloadTableView];
            [tableView reloadData];
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];

    } else {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = _datas[indexPath.row];

            [[DataManager shareManager] updateScrpitStatus:2 numberId:model.uuid];
            [tableView setEditing:NO animated:YES];
            [self reloadTableView];
            [tableView reloadData];
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);

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
        if (model.active) {
            stopAction.image = [UIImage imageNamed:@"stop"];
            stopAction.backgroundColor = RGB(182, 32, 224);
        } else {
            stopAction.image = [UIImage imageNamed:@"play"];
            stopAction.backgroundColor = RGB(182, 32, 224);;
        }
        
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,stopAction]];
    }
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
