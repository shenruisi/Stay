//
//  SYDownloadFolderChooseModalViewController.h
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYDownloadFolderChooseModalViewController : ModalViewController

@property (nonatomic, strong) NSString *excludeUUID;
@property (nonatomic, strong) NSMutableDictionary *dic;
@property(nonatomic,strong) UINavigationController *nav;
@end

NS_ASSUME_NONNULL_END
