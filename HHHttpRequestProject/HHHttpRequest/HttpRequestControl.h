//
//  HttpRequestControl.h
//  HHHttpRequest
//
//  Created by HuHeng on 2017/4/24.
//  Copyright © 2017年 Hu Heng. All rights reserved.
//

/*
 网络连接控制场
 */

#import <Foundation/Foundation.h>
#import "HttpRequestMsg.h"

#define RequestTimeOut 20

@interface HttpRequestControl : NSObject

+ (instancetype)sharedInstance;

/**
 发送一个请求 block形式

 @param requestMsg 封装好的请求参数的msg
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 */
- (void)sendRequestMsg:(HttpRequestMsg *)requestMsg
               success:(SuccessCompletionBlock)successBlock
               failure:(FailureCompletionBlock)failureBlock;

/**
 发送一个请求 delegate形式

 @param msg 封装好的请求参数的msg
 */
- (void)sendRequestMsg:(HttpRequestMsg *)msg;

/**
 取消一个请求

 @param msg 需要取消的msg
 */
- (void)cancelRequestMsg:(HttpRequestMsg *)msg;

/**
 取消所有请求
 */
- (void)cancelAllRequestMsg;

@end
