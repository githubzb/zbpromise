//
//  ZBPromise.m
//  zbpromise
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBPromise.h"

NSErrorDomain const ZBPromiseErrorDomain = @"zb.promise.error";

NSError * ZBError(NSString *reason){
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: reason?:@"",
                               @"reason": reason?:@""};
    return [NSError errorWithDomain:ZBPromiseErrorDomain
                               code:ZBPromiseErrorCodeFail
                           userInfo:userInfo];
}

NSError * ZBErrorTimeOut(void){
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"timeout!",
                               @"reason": @"timeout!"};
    return [NSError errorWithDomain:ZBPromiseErrorDomain
                               code:ZBPromiseErrorCodeTimeOut
                           userInfo:userInfo];
}

NSString * ZBReason(NSError *error){
    if ([error.domain isEqualToString:ZBPromiseErrorDomain]){
        return error.userInfo[@"reason"];
    }
    return error.userInfo[NSLocalizedFailureReasonErrorKey];
}

BOOL ZBErrorIsTimeOut(NSError *error){
    return [error.domain isEqualToString:ZBPromiseErrorDomain] &&
    error.code == ZBPromiseErrorCodeTimeOut;
}

static dispatch_queue_t ZBDefaultDispatchQueue;

@interface ZBPromise ()

@property (nonatomic, strong) NSMutableArray<ZBPromiseCallback> *callbacks;

@end
@implementation ZBPromise

- (void)dealloc{
    if (self.state == ZBPromiseStatePending) {
        //线程同步结束
        dispatch_group_leave(ZBPromise.dispatchGroup);
    }
}

+ (void)initialize {
    if (self == [ZBPromise class]) {
        ZBDefaultDispatchQueue = dispatch_get_main_queue();
    }
}

+ (void)setDefaultDispatchQueue:(dispatch_queue_t)defaultDispatchQueue{
    @synchronized(self){
        ZBDefaultDispatchQueue = defaultDispatchQueue;
    }
}
+ (dispatch_queue_t)defaultDispatchQueue{
    return ZBDefaultDispatchQueue;
}
+ (dispatch_group_t)dispatchGroup{
    static dispatch_group_t group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = dispatch_group_create();
    });
    return group;
}

- (instancetype)initPending{
    self = [super init];
    if (self) {
        //线程同步开始
        dispatch_group_enter(ZBPromise.dispatchGroup);
    }
    return self;
}

+ (instancetype)pending{
    return [[ZBPromise alloc] initPending];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmismatched-parameter-types"
+ (instancetype)setUp:(void (^)(ZBPromise * _Nonnull))callback{
    return [[ZBPromise alloc] initWithSetup:callback];
}
#pragma clang diagnostic pop

+ (instancetype)resolution:(id)obj{
    return [[ZBPromise alloc] initWithResolution:obj];
}

- (void)resolve:(id)value{
    if ([value isKindOfClass:[NSError class]]) {
        [self reject:value];
    }else{
        @synchronized(self){
            if (self.state == ZBPromiseStatePending) {
                _state = ZBPromiseStateFulfilled;
                _value = value;
                for (ZBPromiseCallback callback in self.callbacks) {
                    callback(_state, _value);
                }
                _callbacks = nil;
                //线程同步结束
                dispatch_group_leave(ZBPromise.dispatchGroup);
            }
        }
    }
}

- (void)reject:(NSError *)error{
    if (![error isKindOfClass:[NSError class]]) {
        @throw error.description;
    }else{
        @synchronized(self){
            if (self.state == ZBPromiseStatePending) {
                _state = ZBPromiseStateRejected;
                _error = error;
                for (ZBPromiseCallback callback in self.callbacks) {
                    callback(_state, _error);
                }
                _callbacks = nil;
                //线程同步结束
                dispatch_group_leave(ZBPromise.dispatchGroup);
            }
        }
    }
}

- (void)callbackOnQueue:(dispatch_queue_t)queue
            onFulfilled:(ZBFulfillBlock)fulfilled
             onRejected:(ZBRejectBlock)rejected
{
    @synchronized(self){
        if (self.state == ZBPromiseStateFulfilled && fulfilled) {
            dispatch_group_async(ZBPromise.dispatchGroup, queue, ^{
                fulfilled(self.value);
            });
            return;
        }
        if (self.state == ZBPromiseStateRejected && rejected) {
            dispatch_group_async(ZBPromise.dispatchGroup, queue, ^{
                rejected(self.error);
            });
        }
        if (self.state == ZBPromiseStatePending) {
            ZBPromiseCallback callback = ^(ZBPromiseState state, id obj){
                dispatch_group_async(ZBPromise.dispatchGroup, queue, ^{
                    if (state == ZBPromiseStateFulfilled && fulfilled) {
                        fulfilled(obj);
                        return;
                    }
                    if (state == ZBPromiseStateRejected && rejected) {
                        rejected(obj);
                        return;
                    }
                });
            };
            [self.callbacks addObject:callback];
        }
    }
}

- (ZBPromise *)callbackChainedOnQueue:(dispatch_queue_t)queue
                          onFulfilled:(ZBChainedFulfillBlock)fulfilled
                           onRejected:(ZBChainedRejectBlock)rejected
{
    ZBPromise *promise = [ZBPromise pending];
    __auto_type resolve = ^(id value){
        if ([value isKindOfClass:[ZBPromise class]]) {
            [(ZBPromise *)value callbackOnQueue:queue
                                    onFulfilled:^(id  _Nullable value)
             {
                 [promise resolve:value];
             } onRejected:^(NSError * _Nonnull error) {
                 [promise reject:error];
             }];
        }else{
            [promise resolve:value];
        }
    };
    [self callbackOnQueue:queue onFulfilled:^(id  _Nullable value) {
        id val = fulfilled ? fulfilled(value) : value;
        resolve(val);
    } onRejected:^(NSError * _Nonnull error) {
        id val = rejected ? rejected(error) : error;
        resolve(val);
    }];
    return promise;
}

#pragma mark - private
- (instancetype)initWithSetup:(void(^)(ZBPromise *promise))callback{
    if (callback) {
        self = [self initPending];
        if (self) {
            callback(self);
        }
        return self;
    }
    return nil;
}

- (instancetype)initWithResolution:(id)obj{
    self = [super init];
    if (self) {
        if ([obj isKindOfClass:[NSError class]]) {
            _state = ZBPromiseStateRejected;
            _error = obj;
        }else{
            _state = ZBPromiseStateFulfilled;
            _value = obj;
        }
    }
    return self;
}

- (NSMutableArray<ZBPromiseCallback> *)callbacks{
    if (!_callbacks) {
        _callbacks = [[NSMutableArray alloc] init];
    }
    return _callbacks;
}

@end
