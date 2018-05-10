//
//  DataApiService.m
//  SimpleDemo
//
//  Created by HuHeng on 2017/5/15.
//  Copyright © 2017年 Bric. All rights reserved.
//

#import "DataApiService.h"

@implementation DataApiService

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _httpControl = [HttpRequestControl sharedInstance];
    }
    return self;
}

/**
 子类调用 [super receiveDidFinished:receiveMsg]

 @param receiveMsg <#receiveMsg description#>
 */
- (void)receiveDidFinished:(HttpRequestMsg *)receiveMsg
{
    self.errorMessage = nil;
    NSLog(@"%@.........%s", NSStringFromClass([self class]), __FUNCTION__);
}

/**
 子类调用 [super receiveDidFailed:receiveMsg]

 @param receiveMsg <#receiveMsg description#>
 */
- (void)receiveDidFailed:(HttpRequestMsg *)receiveMsg
{
    [self handleErrorMsg:receiveMsg];
}

#pragma mark - 

- (void)startMsg:(HttpRequestMsg *)msg
         success:(SuccessCompletionBlock)successBlock
         failure:(FailureCompletionBlock)failureBlock
{
    [self.httpControl sendRequestMsg:msg
                             success:^(HttpRequestMsg *msg) {
        
        if (successBlock) {
            successBlock(msg);
        }
        
    } failure:^(HttpRequestMsg *msg) {
        
        [self handleErrorMsg:msg];
        
        if (failureBlock) {
            failureBlock(msg);
        }
    }];
}

- (void)handleErrorMsg:(HttpRequestMsg *)errorMsg
{
    self.errorMessage = nil;
    
    if (errorMsg.errorType == ResponseErrorTypeInvalidJSONFormat)
    {
        self.errorMessage = @"网络数据异常";
    }
    else
    {
        NSInteger code = errorMsg.error.code;
        
        if (code == -1009) {
            // Error Domain=NSURLErrorDomain Code=-1009 "似乎已断开与互联网的连接。
            self.errorMessage = @"网络不可用，请检查网络设置";
        } else if (code == -1001) {
            // 超时
            self.errorMessage = @"网络请求超时，请稍后再试";
        } else if (code == -1004) {
            // 连接不上服务器
            self.errorMessage = @"服务器连接异常";
        } else if (code == -1005) {
            // 网络连接异常
            self.errorMessage = @"网络连接异常";
        } else if (code == -1011) {
            // 服务器响应异常
            self.errorMessage = @"服务器响应异常";
        } else {
            //
            self.errorMessage = @"数据请求异常";
        }
    }
}

@end
