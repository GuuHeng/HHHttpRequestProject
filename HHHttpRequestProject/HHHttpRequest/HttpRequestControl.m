//
//  HttpRequestControl.m
//  HHHttpRequest
//
//  Created by HuHeng on 2017/4/24.
//  Copyright © 2017年 Hu Heng. All rights reserved.
//

#import "HttpRequestControl.h"
#import "AFNetworking.h"
#import <pthread.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

@implementation HttpRequestControl
{
    AFHTTPSessionManager *_sessionManager;
    NSMutableDictionary<NSNumber *, HttpRequestMsg *> *_requestRecord;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    pthread_mutex_t _lock;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HttpRequestControl *control = nil;
    dispatch_once(&onceToken, ^{
        
        control = [[HttpRequestControl alloc] init];
    });
    return control;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json",@"text/javascript", nil];
        _sessionManager.requestSerializer.timeoutInterval = RequestTimeOut;
        
        pthread_mutex_init(&_lock, NULL);
        _requestRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json",@"text/javascript", nil];
        _jsonResponseSerializer.readingOptions = NSJSONReadingMutableContainers;
    }
    return _jsonResponseSerializer;
}

#pragma mark -

- (NSString *)requestUrlWithRequestMsg:(HttpRequestMsg *)msg
{
    if ([msg.baseUrlPath hasSuffix:@"/"]) {
        msg.baseUrlPath = [msg.baseUrlPath substringToIndex:msg.baseUrlPath.length-1];
    }
    
    if (msg.urlPath && msg.urlPath.length > 0) {

        if ([msg.urlPath hasPrefix:@"/"]) {
            return [msg.baseUrlPath stringByAppendingString:msg.urlPath];
        }
        else {
            return [msg.baseUrlPath stringByAppendingFormat:@"/%@", msg.urlPath];
        }
    }
    else {
        return msg.baseUrlPath;
    }
}

- (void)sendRequestMsg:(HttpRequestMsg *)requestMsg
               success:(SuccessCompletionBlock)successBlock
               failure:(FailureCompletionBlock)failureBlock
{
    requestMsg.successBlock = successBlock;
    requestMsg.failureBlock = failureBlock;
    [self sendRequestMsg:requestMsg];
}

- (void)sendRequestMsg:(HttpRequestMsg *)msg
{
    NSError *error = nil;
    
    msg.requestTask = [self sessionDataTaskForRequestMsg:msg error:&error];
    
    if (error) {
        
        [msg.delegate receiveDidFailed:msg];
        // 失败、错误
        return;
    }
    
    [self addRequestMsgToRecord:msg];
    [msg.requestTask resume];
}

- (void)addRequestMsgToRecord:(HttpRequestMsg *)msg
{
    Lock();
    _requestRecord[@(msg.requestTask.taskIdentifier)] = msg;
    Unlock();
}

- (void)removeRequestMsgFromRecord:(HttpRequestMsg *)msg
{
    Lock();
    [_requestRecord removeObjectForKey:@(msg.requestTask.taskIdentifier)];
    Unlock();
}

- (void)cancelRequestMsg:(HttpRequestMsg *)msg
{
    [msg.requestTask cancel];
    Lock();
    [_requestRecord removeObjectForKey:@(msg.requestTask.taskIdentifier)];
    Unlock();
}

- (void)cancelAllRequestMsg
{
    Lock();
    NSArray *keys = _requestRecord.allKeys;
    Unlock();
    
    if (keys && keys.count > 0) {
        NSArray *copyKeys = [keys copy];
        for (NSNumber *key in copyKeys) {
            Lock();
            HttpRequestMsg *msg = _requestRecord[key];
            Unlock();
            [msg cancelRequest];
        }
    }
}

#pragma mark -

- (NSURLSessionDataTask *)sessionDataTaskForRequestMsg:(HttpRequestMsg *)msg error:(NSError * _Nullable __autoreleasing *)error
{
    RequestMethod method = msg.requestMethod;
    NSString *url = [self requestUrlWithRequestMsg:msg];
    
    NSDictionary *paramDict = msg.paramDict;
    
    AFConstructingBlock constructingBlock = msg.constructingBodyBlock;
    
    switch (method) {
        case RequestMethodGET:
            return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:_sessionManager.requestSerializer URLString:url parameters:paramDict error:error];
            break;
        case RequestMethodPOST:
        case RequestMethodPOST_UPLOAD:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:_sessionManager.requestSerializer URLString:url parameters:paramDict constructingBodyWithBlock:constructingBlock error:error];
            break;
            
        default:
            break;
    }
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest *request = nil;
    
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_sessionManager dataTaskWithRequest:request
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *_error) {
                               
                               [self handleRequestResult:dataTask responseObject:responseObject error:_error];
                               
                           }];
    return dataTask;
}

#pragma mark -

- (void)handleRequestResult:(NSURLSessionDataTask *)dataTask responseObject:(id)responseObject error:(NSError *)error
{
    Lock();
    HttpRequestMsg *msg = _requestRecord[@(dataTask.taskIdentifier)];
    Unlock();
    
    if (!msg) {
        return;
    }
    
    NSError * __autoreleasing serializationError = nil;
    NSError *requestError = nil;
    BOOL isSucceed = NO;
    
    if ([responseObject isKindOfClass:[NSData class]]) {
        if (msg.responseFormat == ResponseFormatTypeJSON) {
            msg.responseObject = responseObject;
            msg.responseJsonDict = [self.jsonResponseSerializer responseObjectForResponse:dataTask.response data:responseObject error:&serializationError];
        } else if (msg.responseFormat == ResponseFormatTypeData) {
            msg.responseObject = responseObject;
        }
    }

    if (error) {
        // failure
        requestError = error;
        msg.errorType = ResponseErrorTypeInvalidStatusCode;
        isSucceed = NO;
        
    } else if (serializationError) {
        
        requestError = serializationError;
        msg.errorType = ResponseErrorTypeInvalidJSONFormat;
        isSucceed = NO;
        
    } else {
        
        if (msg.responseFormat == ResponseFormatTypeJSON) {
            isSucceed = [NSJSONSerialization isValidJSONObject:msg.responseJsonDict];
        } else if (msg.responseFormat == ResponseFormatTypeData) {
            isSucceed = YES;
        }
    }
    
    if (isSucceed) {
        
        if (msg.delegate != nil && [msg.delegate respondsToSelector:@selector(receiveDidFinished:)]) {
            [msg.delegate receiveDidFinished:msg];
        }
        
        if (msg.successBlock) {
            msg.successBlock(msg);
        }
    }
    else {
        msg.error = requestError;
        if (msg.delegate != nil && [msg.delegate respondsToSelector:@selector(receiveDidFailed:)]) {
            [msg.delegate receiveDidFailed:msg];
        }
        
        if (msg.failureBlock) {
            msg.failureBlock(msg);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestMsgFromRecord:msg];
    });
    
}

@end
