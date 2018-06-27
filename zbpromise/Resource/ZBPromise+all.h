//
//  ZBPromise+all.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZBPromise (all)

- (ZBPromise<NSArray *> *)all:(NSArray<ZBPromise *> *)all;
- (ZBPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue
                              all:(NSArray<ZBPromise *> *)all;
+ (ZBPromise<NSArray *> *)all:(NSArray<ZBPromise *> *)all;
+ (ZBPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue
                              all:(NSArray<ZBPromise *> *)all;

///点调用
- (ZBPromise<NSArray *> *(^)(NSArray<ZBPromise *> *))all;
- (ZBPromise<NSArray *> *(^)(dispatch_queue_t, NSArray<ZBPromise *> *))allOn;

+ (ZBPromise<NSArray *> *(^)(NSArray<ZBPromise *> *))all;
+ (ZBPromise<NSArray *> *(^)(dispatch_queue_t, NSArray<ZBPromise *> *))allOn;

@end
NS_ASSUME_NONNULL_END
