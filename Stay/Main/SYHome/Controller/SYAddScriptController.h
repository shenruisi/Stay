//
//  SYAddScriptController.h
//  Stay
//
//  Created by zly on 2022/4/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYAddScriptController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *data;


@end

NS_ASSUME_NONNULL_END
