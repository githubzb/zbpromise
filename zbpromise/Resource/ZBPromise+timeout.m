//
//  ZBPromise+timeout.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise+timeout.h"

@implementation ZBPromise (timeout)

- (ZBPromise *)timeout:(NSTimeInterval)time{
    return [self onQueue:ZBPromise.defaultDispatchQueue timeout:time];
}

- (ZBPromise *)onQueue:(dispatch_queue_t)queue timeout:(NSTimeInterval)time{
    return [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        [self callbackOnQueue:queue onFulfilled:^(id  _Nullable value) {
            [promise resolve:value];
        } onRejected:^(NSError * _Nonnull error) {
            [promise reject:error];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), queue, ^{
            [promise reject:ZBErrorTimeOut()];
        });
    }];
}

- (ZBPromise *(^)(NSTimeInterval))timeout{
    return ^(NSTimeInterval time){
        return [self timeout:time];
    };
}

- (ZBPromise *(^)(dispatch_queue_t, NSTimeInterval))timeoutOn{
    return ^(dispatch_queue_t queue, NSTimeInterval time){
        return [self onQueue:queue timeout:time];
    };
}

@end
