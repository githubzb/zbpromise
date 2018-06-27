//
//  ZBPromise+zcatch.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef id __nullable (^ZBCatchBlock)(NSError *error);

@interface ZBPromise (zcatch)

- (ZBPromise *)zcatch:(ZBCatchBlock)callback;
- (ZBPromise *)onQueue:(dispatch_queue_t)queue catch:(ZBCatchBlock)callback;

///点调用
- (ZBPromise *(^)(ZBCatchBlock))zcatch;
- (ZBPromise *(^)(dispatch_queue_t, ZBCatchBlock))catchOn;

@end

NS_ASSUME_NONNULL_END
