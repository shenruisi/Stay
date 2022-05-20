//
//  BrowseView.m
//  Stay
//
//  Created by zly on 2022/5/10.
//

#import "BrowseView.h"
#import "SYEditViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <CommonCrypto/CommonDigest.h>

@implementation BrowseView

- (instancetype)initWithFrame:(CGRect)frame{
    self  = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    [self addSubview:self.titleLabel];
    [self addSubview:self.authorLabel];
    [self addSubview:self.descLabel];
    [self addSubview:self.addBtn];
    [self addSubview:self.rightBtn];
}

- (void)loadView:(NSDictionary *)dic {
    self.titleLabel.text = dic[@"name"];
    self.authorLabel.text = dic[@"author"];
    self.descLabel.text = dic[@"description"];
    self.authorLabel.top = self.titleLabel.bottom + 5;
    self.descLabel.top = self.authorLabel.bottom + 5;
    self.addBtn.top = self.rightBtn.top = 8;
    self.addBtn.right = self.rightBtn.right = 220;
    NSString *uuidName = [NSString stringWithFormat:@"%@%@",dic[@"name"],dic[@"namespace"]];
    NSString *uuid = [self md5HexDigest:uuidName];
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];

    if(entity == nil) {
        self.rightBtn.hidden = true;
    } else {
        self.addBtn.hidden = true;
    }
    downloadUrl = dic[@"downloadURL"];
    
}

- (void)addScript:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:@"needShowLoading" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];

    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
    dispatch_async(dispatch_get_main_queue(),^{
        NSNotification *notification = [NSNotification notificationWithName:@"needStopLoading" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
        if(data != nil ) {
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            SYEditViewController *cer = [[SYEditViewController alloc] init];
            cer.content = str;
            [self.navigationController pushViewController:cer animated:true];
        }
    });
}


- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 200, 32)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor blackColor];

    }
    return _titleLabel;
}


- (UILabel *)authorLabel {
    if(_authorLabel == nil) {
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 18)];
        _authorLabel.font = [UIFont systemFontOfSize:16];
        _authorLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        _authorLabel.textColor = [UIColor blackColor];
    }
    return _authorLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 42)];
        _descLabel.font = [UIFont systemFontOfSize:16];
        _descLabel.numberOfLines = 2;
        _descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        _descLabel.textColor = RGB(138, 138, 138);
    }
    return _descLabel;
}

- (UIButton *)rightBtn {
    if(_rightBtn == nil) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 26, 24);
        [_rightBtn setImage:[UIImage imageNamed:@"addedScript"] forState:UIControlStateNormal];
        
    }
    return  _rightBtn;
}

- (UIButton *)addBtn {
    if(_addBtn == nil) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, 0, 26, 24);
        [_addBtn setImage:[UIImage imageNamed:@"addScript"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addScript:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

@end
