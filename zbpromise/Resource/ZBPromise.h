//
//  ZBPromise.h
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const ZBPromiseErrorDomain;

typedef NS_ENUM(NSInteger, ZBPromiseErrorCode) {
    ZBPromiseErrorCodeFail = 0,
    ZBPromiseErrorCodeTimeOut = 1
};

FOUNDATION_EXPORT NSError * ZBError(NSString *reason);
FOUNDATION_EXPORT NSError * ZBErrorTimeOut(void);
FOUNDATION_EXPORT NSString * ZBReason(NSError *error);
FOUNDATION_EXPORT BOOL ZBErrorIsTimeOut(NSError *error);

//定义Promise状态
typedef NS_ENUM(NSInteger, ZBPromiseState) {
    ZBPromiseStatePending   = 0,
    ZBPromiseStateFulfilled = 1,
    ZBPromiseStateRejected  = 2
};

@interface ZBPromise<__covariant ObjectType> : NSObject

typedef void(^ZBPromiseCallback)(ZBPromiseState state, __nullable id obj);
typedef void(^__nullable ZBFulfillBlock)(__nullable ObjectType value);
typedef void(^__nullable ZBRejectBlock)(NSError *error);
typedef id __nullable (^__nullable ZBChainedFulfillBlock)(__nullable ObjectType value);
typedef id __nullable (^__nullable ZBChainedRejectBlock)(NSError *error);


/**
 Promise默认执行的队列，default：main
 */
@property (class) dispatch_queue_t defaultDispatchQueue;
@property (class, readonly) dispatch_group_t dispatchGroup;
@property (nonatomic, readonly) ZBPromiseState state;
@property (nullable, nonatomic, readonly) ObjectType value;
@property (nonatomic, readonly) NSError *error;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initPending;
/**
 初始化一个Pending状态的Promise
 
 @return    ZBPromise
 */
+ (instancetype)pending;
+ (instancetype)setUp:(void(^)(ZBPromise<ObjectType> *promise))callback;
+ (instancetype)resolution:(nullable id)obj;

- (void)resolve:(nullable ObjectType)value;
- (void)reject:(NSError *)error;

/**
 执行回调
 
 @param queue       队列
 @param fulfilled   成功回调
 @param rejected    失败回调
 */
- (void)callbackOnQueue:(dispatch_queue_t)queue
            onFulfilled:(ZBFulfillBlock)fulfilled
             onRejected:(ZBRejectBlock)rejected;

/**
 执行回调（链式调用）
 
 @param queue       队列
 @param fulfilled   成功回调
 @param rejected    失败回调
 @return            ZBPromise
 */
- (ZBPromise *)callbackChainedOnQueue:(dispatch_queue_t)queue
                          onFulfilled:(ZBChainedFulfillBlock)fulfilled
                           onRejected:(ZBChainedRejectBlock)rejected;

@end

NS_ASSUME_NONNULL_END
