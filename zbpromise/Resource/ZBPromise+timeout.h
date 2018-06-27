//
//  ZBPromise+timeout.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

@interface ZBPromise (timeout)

- (ZBPromise *)timeout:(NSTimeInterval)time;
- (ZBPromise *)onQueue:(dispatch_queue_t)queue timeout:(NSTimeInterval)time;

///点调用
- (ZBPromise *(^)(NSTimeInterval))timeout;
- (ZBPromise *(^)(dispatch_queue_t, NSTimeInterval))timeoutOn;

@end
