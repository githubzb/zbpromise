//
//  ZBPromise+then.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise+then.h"

@implementation ZBPromise (then)

- (ZBPromise *)then:(ZBThenBlock)callback{
    return [self onQueue:ZBPromise.defaultDispatchQueue then:callback];
}

- (ZBPromise *)onQueue:(dispatch_queue_t)queue then:(ZBThenBlock)then{
    return [self callbackChainedOnQueue:queue onFulfilled:then onRejected:nil];
}

- (ZBPromise *(^)(ZBThenBlock))then{
    return ^ZBPromise *(ZBThenBlock callback){
        return [self then:callback];
    };
}

- (ZBPromise *(^)(dispatch_queue_t, ZBThenBlock))thenOn{
    return ^ZBPromise *(dispatch_queue_t queue, ZBThenBlock callback){
        return [self onQueue:queue then:callback];
    };
}

@end
