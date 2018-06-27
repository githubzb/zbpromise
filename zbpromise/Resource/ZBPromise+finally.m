//
//  ZBPromise+finally.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise+finally.h"

@implementation ZBPromise (finally)

- (ZBPromise *)finally:(ZBFinallyBlock)callback{
    return [self onQueue:ZBPromise.defaultDispatchQueue finally:callback];
}

- (ZBPromise *)onQueue:(dispatch_queue_t)queue finally:(ZBFinallyBlock)callback{
    return [self callbackChainedOnQueue:queue onFulfilled:^id (id value) {
        if (callback) {
            callback(value);
        }
        return nil;
    } onRejected:^id (NSError * error) {
        if (callback) {
            callback(error);
        }
        return nil;
    }];
}

- (ZBPromise * (^)(ZBFinallyBlock))finally{
    return ^ZBPromise *(ZBFinallyBlock callback){
        return [self finally:callback];
    };
}

- (ZBPromise * (^)(dispatch_queue_t queue, ZBFinallyBlock callback))finallyOn{
    return ^ZBPromise *(dispatch_queue_t queue, ZBFinallyBlock callback){
        return [self onQueue:queue finally:callback];
    };
}

@end
