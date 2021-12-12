//
//  SYDetailViewController.m
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import "SYDetailViewController.h"
#import "DataManager.h"
#import "SYEditViewController.h"

@interface SYDetailViewController ()

@end

@implementation SYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(242, 242, 246);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0,200,44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:self.script.name];
    label.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = label;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self createDetailView];
    // Do any additional setup after loading the view.
}


- (void)createDetailView{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.width ,self.view.height)];
    
    [self.view addSubview:scrollView];
    
    UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 271)];
    detailView.backgroundColor = [UIColor whiteColor];
    detailView.layer.cornerRadius = 8;
    [scrollView addSubview:detailView];
    
    UILabel *nameLabel = [self createDefaultLabelWithText:self.script.name];
    nameLabel.top = 13;
    nameLabel.left = 17;
    [detailView addSubview:nameLabel];
    
    UIView *line = [self createLine];
    line.top = nameLabel.bottom + 13;
    [detailView addSubview:line];
    
    if(!self.isSearch) {
        UISwitch *scriptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10,99,42 ,27)];
        scriptSwitch.centerY = nameLabel.centerY;
        scriptSwitch.right = kScreenWidth - 48;
        [scriptSwitch setOn: self.script.active];
        [detailView addSubview:scriptSwitch];
        [scriptSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    UILabel *authorLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.author","author")];
    authorLabel.top = line.bottom +13;
    authorLabel.left = 17;
    [detailView addSubview:authorLabel];
    
    UILabel *authorNameLabel = [self createDefaultLabelWithText:self.script.author];
    authorNameLabel.top = line.bottom + 13;
    authorNameLabel.right = kScreenWidth - 48;
    authorNameLabel.textColor = RGB(138, 138, 138);
    [detailView addSubview:authorNameLabel];
    
    UIView *line2 =  [self createLine];
    line2.top = authorLabel.bottom + 13;
    [detailView addSubview:line2];
    
    UILabel *versionLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.version","Version")];
    versionLabel.top = line2.bottom +13;
    versionLabel.left = 17;
    [detailView addSubview:versionLabel];
    
    UILabel *versionNameLabel = [self createDefaultLabelWithText:self.script.version];
    versionNameLabel.top = line2.bottom + 13;
    versionNameLabel.right = kScreenWidth - 48;
    versionNameLabel.textColor = RGB(138, 138, 138);
    [detailView addSubview:versionNameLabel];
    
    UIView *line7 = [self createLine];
    line7.top = versionLabel.bottom + 13;
    [detailView addSubview:line7];
    
    
    UILabel *scriptLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.scriptContent","Script Content")];
    scriptLabel.top = line7.bottom +13;
    scriptLabel.left = 17;
    [detailView addSubview:scriptLabel];
    
    UIImageView *scriptIconLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    scriptIconLabel.right = kScreenWidth - 48;
    scriptIconLabel.centerY = scriptLabel.centerY;
    [detailView addSubview:scriptIconLabel];
    
    UIButton *scriptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scriptBtn.frame = CGRectMake(0, 0, kScreenWidth, 40);
    scriptBtn.centerY = scriptLabel.centerY;
    scriptBtn.right = kScreenWidth - 48;

    [scriptBtn addTarget:self action:@selector(showScript:) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:scriptBtn];
  
    
    UIView *line3 = [self createLine];
    line3.top = scriptLabel.bottom + 13;
    [detailView addSubview:line3];
    
    UILabel *pageLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.sourcePage","Source Page")];
    pageLabel.top = line3.bottom +13;
    pageLabel.left = 17;
    [detailView addSubview:pageLabel];
    
    
    UIView *line4 = [self createLine];
    line4.top = pageLabel.bottom + 13;
    [detailView addSubview:line4];
    
    UILabel *descLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.descDetail","Description")];
    descLabel.top = line4.bottom +13;
    descLabel.left = 17;
    [detailView addSubview:descLabel];
    
    UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,50)];
    descDetailLabel.font = [UIFont systemFontOfSize:17];
    descDetailLabel.text = self.script.desc;
    descDetailLabel.top = descLabel.bottom +13;
    descDetailLabel.left = 17;
    descDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descDetailLabel.textColor = RGB(138, 138, 138);
    descDetailLabel.textAlignment = NSTextAlignmentLeft;
    descDetailLabel.numberOfLines = 2;
    [descDetailLabel sizeToFit];
    [detailView addSubview:descDetailLabel];
    
    detailView.height = descDetailLabel.bottom + 13;
    
    UILabel *configLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,22)];
    configLabel.font = [UIFont systemFontOfSize:17];
    configLabel.text = [NSString stringWithFormat:@"%@\"%@\"",@"CONIFGURATION FOR",self.script.name];
    configLabel.top = detailView.bottom +40;
    configLabel.left = 17;
    configLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    configLabel.textColor = RGB(138, 138, 138);
    [scrollView addSubview:configLabel];
    
    
    UIView *configView = [[UIView alloc] initWithFrame:CGRectMake(16, 120, kScreenWidth - 40, 238)];
    configView.backgroundColor = [UIColor whiteColor];
    configView.layer.cornerRadius = 8;
    configView.top = configLabel.bottom + 16;
    [scrollView addSubview:configView];
    
    UILabel *matchLabel = [self createDefaultLabelWithText:@"Matches"];
    matchLabel.top = 13;
    matchLabel.left = 17;
    [configView addSubview:matchLabel];
    
    UILabel *matchDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,22)];
    matchDetailLabel.font = [UIFont systemFontOfSize:17];
    if (self.script.mathes.count > 0) {
        matchDetailLabel.text = [NSString stringWithFormat:@"[%@]", [self.script.mathes componentsJoinedByString:@","]];
    } else {
     matchDetailLabel.text = @"[]";
    }
    matchDetailLabel.top = matchLabel.bottom +13;
    matchDetailLabel.left = 17;
    matchDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    matchDetailLabel.textColor = RGB(138, 138, 138);
    [configView addSubview:matchDetailLabel];
    
    UIView *line5 = [self createLine];;
    line5.top = matchDetailLabel.bottom + 9;
    [configView addSubview:line5];
    
    UILabel *includesLabel = [self createDefaultLabelWithText:@"includes"];
    includesLabel.top = line5.bottom + 13;
    includesLabel.left = 17;
    [configView addSubview:includesLabel];
    
    UILabel *includesDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,22)];
    includesDetailLabel.font = [UIFont systemFontOfSize:17];
    if (self.script.includes.count > 0) {
        includesDetailLabel.text = [NSString stringWithFormat:@"[%@]", [self.script.includes componentsJoinedByString:@","]];
    } else {
        includesDetailLabel.text = @"[]";
    }
    includesDetailLabel.top = includesLabel.bottom +13;
    includesDetailLabel.left = 17;
    includesDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    includesDetailLabel.textColor = RGB(138, 138, 138);
    [configView addSubview:includesDetailLabel];
    
    UIView *line8 = [self createLine];
    line8.top = includesDetailLabel.bottom + 9;
    [configView addSubview:line8];
    
    UILabel *excludesLabel =  [self createDefaultLabelWithText:@"excludes"];
    excludesLabel.top = line8.bottom + 13;
    excludesLabel.left = 17;
    [configView addSubview:excludesLabel];
    
    UILabel *excludesDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,22)];
    excludesDetailLabel.font = [UIFont systemFontOfSize:17];
    if (self.script.excludes.count > 0) {
        excludesDetailLabel.text = [NSString stringWithFormat:@"[%@]", [self.script.excludes componentsJoinedByString:@","]];
    } else {
        excludesDetailLabel.text = @"[]";
    }
    excludesDetailLabel.top = excludesLabel.bottom + 13;
    excludesDetailLabel.left = 17;
    excludesDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    excludesDetailLabel.textColor = RGB(138, 138, 138);
    [configView addSubview:excludesDetailLabel];
    
    UIView *line9 = [self createLine];
    line9.top = excludesDetailLabel.bottom + 9;
    [configView addSubview:line9];
    
    UILabel *runAtLabel = [self createDefaultLabelWithText:@"Run at"];
    runAtLabel.top = line9.bottom + 13;
    runAtLabel.left = 17;
    [configView addSubview:runAtLabel];
    
    
    UILabel *runAtDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,22)];
    runAtDetailLabel.font = [UIFont systemFontOfSize:17];
    runAtDetailLabel.text = self.script.runAt;
    runAtDetailLabel.top = runAtLabel.bottom +13;
    runAtDetailLabel.left = 17;
    runAtDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    runAtDetailLabel.textColor = RGB(138, 138, 138);
    [configView addSubview:runAtDetailLabel];
    
    UIView *line6 = [self createLine];
    line6.top = runAtDetailLabel.bottom + 9;
    [configView addSubview:line6];
    
    UILabel *grantsLabel = [self createDefaultLabelWithText:@"Grants"];
    grantsLabel.top = line6.bottom + 13;
    grantsLabel.left = 17;
    [configView addSubview:grantsLabel];
    
    UILabel *grantsDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 62 ,500)];
    grantsDetailLabel.font = [UIFont systemFontOfSize:17];
    if (self.script.grants.count > 0) {
        grantsDetailLabel.text = [NSString stringWithFormat:@"[%@]", [self.script.grants componentsJoinedByString:@","]];
    } else {
        grantsDetailLabel.text = @"[]";
    }
    grantsDetailLabel.top = grantsLabel.bottom +13;
    grantsDetailLabel.left = 17;
    grantsDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    grantsDetailLabel.numberOfLines = 0;
    [grantsDetailLabel sizeToFit];
    grantsDetailLabel.textColor = RGB(138, 138, 138);
    [configView addSubview:grantsDetailLabel];
    configView.height =  grantsDetailLabel.bottom + 13;
    scrollView.scrollEnabled = true;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, configView.bottom  + 37, kScreenWidth - 40, 45);
    btn.backgroundColor = RGB(185,101,223);
    if(self.isSearch){
        if(!self.script.active) {
            [btn setTitle:NSLocalizedString(@"settings.add","Add") forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            btn.layer.cornerRadius = 8;
            btn.centerX = scrollView.centerX;
            [btn addTarget:self action:@selector(addScript:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:btn];
            [scrollView setContentSize:CGSizeMake(kScreenWidth, btn.bottom + 15)];
        } else {
            [scrollView setContentSize:CGSizeMake(kScreenWidth, configView.bottom + 15)];
        }
    } else {
        [btn setTitle:NSLocalizedString(@"settings.delete","Delete") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        btn.layer.cornerRadius = 8;
        btn.centerX = scrollView.centerX;
        [btn addTarget:self action:@selector(deleteScript:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn];
        [scrollView setContentSize:CGSizeMake(kScreenWidth, btn.bottom + 15)];
    }
}

- (void)deleteScript:(id)sender {
    self.isSearch = true;
    [[DataManager shareManager] deleteScriptInUserScriptByNumberId: self.script.uuid];
    [[DataManager shareManager]  updateLibScrpitStatus:0 numberId:self.script.uuid];
    for (UIView *subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    [self createDetailView];
}

- (void)addScript:(id)sender {
    self.isSearch = false;
    [[DataManager shareManager] insertToUserScriptnumberId: self.script.uuid];
    [[DataManager shareManager] updateLibScrpitStatus:1 numberId: self.script.uuid];
    for (UIView *subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    [self createDetailView];
}

- (void)showScript:(id)sender {
    SYEditViewController *cer = [[SYEditViewController alloc] init];
    cer.content = self.script.content;
    cer.uuid = self.script.uuid;
    cer.userScript = self.script;
    cer.isEdit = true;
    [self.navigationController pushViewController:cer animated:true];
}

- (void) switchAction:(UISwitch *) scriptSwitch {
    if (scriptSwitch.on == YES) {
        [[DataManager shareManager] updateScrpitStatus:1 numberId:self.script.uuid];
    } else {
        [[DataManager shareManager] updateScrpitStatus:0 numberId:self.script.uuid];
    }
    
}

- (UIView *)createLine{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 57 ,1)];
    [line setBackgroundColor:RGBA(216, 216, 216, 0.3)];
    return line;
}

- (UILabel *)createDefaultLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:17];
    label.text = text;
    [label sizeToFit];
    return  label;
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
