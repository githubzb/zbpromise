//
//  ViewController.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ViewController.h"
#import "PromiseHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [promise resolve:@"Hello"];
            [promise reject:ZBError(@"fail!")];
        });
    }].timeout(6).then(^id(NSString *say){
        NSLog(@"----say:%@", say);
        return say;
    }).zcatch(^id(NSError *error){
        if (ZBErrorIsTimeOut(error)) {
            NSLog(@"time out!");
        }else{
            NSLog(@"error:%@", error);
        }
        return error;
    }).finally(^(id value){
        NSLog(@"-----finish");
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
