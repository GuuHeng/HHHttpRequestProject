//
//  DataApiService.h
//  SimpleDemo
//
//  Created by HuHeng on 2017/5/15.
//  Copyright © 2017年 Bric. All rights reserved.
//

/*
 数据service的父类，所有的service都必须继承该类
 */

#import <Foundation/Foundation.h>
#import "HttpRequestMsg.h"
#import "HttpRequestControl.h"

@interface DataApiService : NSObject<HttpResponseDelegate>

@property (nonatomic, strong, readonly) HttpRequestControl *httpControl;

@property (nonatomic, copy) NSString *errorMessage;


/**
 block

 @param msg <#msg description#>
 @param successBlock <#successBlock description#>
 @param failureBlock <#failureBlock description#>
 */
- (void)startMsg:(HttpRequestMsg *)msg
         success:(SuccessCompletionBlock)successBlock
         failure:(FailureCompletionBlock)failureBlock;

@end
