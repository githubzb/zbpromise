//
//  ZBPromise+finally.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZBFinallyBlock)(__nullable id value);

@interface ZBPromise (finally)

- (ZBPromise *)finally:(ZBFinallyBlock)callback;
- (ZBPromise *)onQueue:(dispatch_queue_t)queue finally:(ZBFinallyBlock)callback;

///点操作
- (ZBPromise *(^)(ZBFinallyBlock))finally;
- (ZBPromise *(^)(dispatch_queue_t, ZBFinallyBlock))finallyOn;

@end
NS_ASSUME_NONNULL_END
