//
//  ZBPromise+zcatch.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise+zcatch.h"

@implementation ZBPromise (zcatch)

- (ZBPromise *)zcatch:(ZBCatchBlock)callback{
    return [self onQueue:ZBPromise.defaultDispatchQueue catch:callback];
}

- (ZBPromise *)onQueue:(dispatch_queue_t)queue catch:(ZBCatchBlock)callback{
    return [self callbackChainedOnQueue:queue onFulfilled:nil onRejected:callback];
}

- (ZBPromise * _Nonnull (^)(ZBCatchBlock _Nonnull))zcatch{
    return ^ZBPromise *(ZBCatchBlock callback){
        return [self zcatch:callback];
    };
}

- (ZBPromise * _Nonnull (^)(dispatch_queue_t _Nonnull, ZBCatchBlock _Nonnull))catchOn{
    return ^ZBPromise *(dispatch_queue_t queue, ZBCatchBlock callback){
        return [self onQueue:queue catch:callback];
    };
}

@end
