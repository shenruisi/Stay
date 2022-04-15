//
//  SYAddScriptController.m
//  Stay
//
//  Created by zly on 2022/4/6.
//

#import "SYAddScriptController.h"
#import "SYEditViewController.h"

@interface SYAddScriptController ()

@end

@implementation SYAddScriptController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.top = 10;
    
    self.data = [[NSMutableArray alloc] initWithObjects:@"新增脚本",@"从链接添加", @"从GreasyFork添加",nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addScriptClick" object:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.data[indexPath.row]];
    return cell;
}

- (CGSize)preferredContentSize {
       if (self.presentingViewController && self.tableView != nil) {
           CGSize tempSize = self.presentingViewController.view.bounds.size;
           tempSize.width = 170;
            //sizeThatFits返回的是最合适的尺寸，但不会改变控件的大小
           CGSize size = [self.tableView sizeThatFits:tempSize];
           return size;
       }else {
           return [super preferredContentSize];
        }
}
- (void)setPreferredContentSize:(CGSize)preferredContentSize{
   super.preferredContentSize = preferredContentSize;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
