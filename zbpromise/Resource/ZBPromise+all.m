//
//  ZBPromise+all.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise+all.h"

@implementation ZBPromise (all)

- (ZBPromise<NSArray *> *)all:(NSArray<ZBPromise *> *)all{
    return [self onQueue:ZBPromise.defaultDispatchQueue all:all];
}

- (ZBPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue all:(NSArray<ZBPromise *> *)all{
    return [ZBPromise<NSArray *> setUp:^(ZBPromise<NSArray *> * _Nonnull promise) {
        if (all.count==0) {
            [promise resolve:@[]];
        }else{
            NSArray *promises = [all copy];
            for (id obj in promises) {
                if (![obj isKindOfClass:[ZBPromise class]]) {
                    [promise reject:ZBError(@"all:参数类型不匹配")];
                    return;
                }
            }
            for (ZBPromise *p in promises) {
                [p callbackOnQueue:queue onFulfilled:^(id  _Nullable value){
                    
                    for (ZBPromise *pro in promises) {
                        if (pro.state != ZBPromiseStateFulfilled) {
                            return;
                        }
                    }
                    [promise resolve:[promises valueForKey:NSStringFromSelector(@selector(value))]];
                    
                } onRejected:^(NSError * _Nonnull error) {
                    [promise reject:error];
                }];
            }
        }
    }];
}

+ (ZBPromise<NSArray *> *)all:(NSArray<ZBPromise *> *)all{
    return [[ZBPromise pending] all:all];
}

+ (ZBPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue all:(NSArray<ZBPromise *> *)all{
    return [[ZBPromise pending] onQueue:queue all:all];
}

- (ZBPromise<NSArray *> * _Nonnull (^)(NSArray<ZBPromise *> * _Nonnull))all{
    return ^(NSArray *all){
        return [self all:all];
    };
}

- (ZBPromise<NSArray *> * _Nonnull (^)(dispatch_queue_t _Nonnull, NSArray<ZBPromise *> * _Nonnull))allOn{
    return ^(dispatch_queue_t queue, NSArray *all){
        return [self onQueue:queue all:all];
    };
}

+ (ZBPromise<NSArray *> * _Nonnull (^)(NSArray<ZBPromise *> * _Nonnull))all{
    return [ZBPromise pending].all;
}

+ (ZBPromise<NSArray *> * _Nonnull (^)(dispatch_queue_t _Nonnull, NSArray<ZBPromise *> * _Nonnull))allOn{
    return [ZBPromise pending].allOn;
}

@end
