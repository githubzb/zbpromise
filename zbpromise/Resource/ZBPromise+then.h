//
//  ZBPromise+then.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZBPromise<ObjectType> (then)

typedef id __nullable (^ZBThenBlock)(ObjectType __nullable value);

- (ZBPromise *)then:(ZBThenBlock)callback;
- (ZBPromise *)onQueue:(dispatch_queue_t)queue then:(ZBThenBlock)then;

///点调用
- (ZBPromise * (^)(ZBThenBlock))then;
- (ZBPromise * (^)(dispatch_queue_t, ZBThenBlock))thenOn;

@end

NS_ASSUME_NONNULL_END
