//
//  HttpRequestMsg.h
//  HHHttpRequest
//
//  Created by HuHeng on 2017/4/24.
//  Copyright © 2017年 Hu Heng. All rights reserved.
//

/*
 网络请求信息的封装类
 */

#import <Foundation/Foundation.h>
#import "MsgConstant.h"
#import "AFNetworking.h"

@class HttpRequestMsg;

/**
 请求方法类型

 - POST: post
 - GET: get
 */
typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodPOST = 0,
    RequestMethodGET,
    RequestMethodPOST_UPLOAD
};

/**
 返回数据格式

 - JSON: Json格式
 - Data: 不符合Json格式
 */
typedef NS_ENUM(NSInteger, ResponseFormatType) {
    ResponseFormatTypeJSON = 0,
    ResponseFormatTypeData
};

/**
 解析错误invalid json;网络请求错误

 - ResponseErrorTypeInvalidJSONFormat: 无效json
 - ResponseErrorTypeInvalidStatusCode: 请求错误
 */
typedef NS_ENUM(NSInteger, ResponseErrorType) {
    ResponseErrorTypeNone = 0,
    ResponseErrorTypeInvalidJSONFormat,
    ResponseErrorTypeInvalidStatusCode
};

/**
 成功回调

 @param msg 请求msg
 */
typedef void(^SuccessCompletionBlock)(HttpRequestMsg *msg);

/**
 失败回调

 @param msg 请求msg
 */
typedef void(^FailureCompletionBlock)(HttpRequestMsg *msg);

@protocol AFMultipartFormData;

/**
 post 上传

 @param formData 上传数据
 */
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol HttpResponseDelegate;

@interface HttpRequestMsg : NSObject


/**
 block 成功回调
 */
@property (nonatomic, copy) SuccessCompletionBlock successBlock;

/**
 block 失败回调
 */
@property (nonatomic, copy) FailureCompletionBlock failureBlock;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

/**
 请求标识 区别请求
 */
@property (nonatomic, assign) MsgCMDCode cmdCode;

/**
 请求方式 default: POST
 */
@property (nonatomic, assign) RequestMethod requestMethod;

/**
 ***返回数据格式 default: JSON
 ***不是JSON格式，需要修改该属性
 */
@property (nonatomic, assign) ResponseFormatType responseFormat;

/**
 HttpResponseDelegate
 */
@property (nonatomic, weak) id<HttpResponseDelegate>delegate;


/////////////////////////////////////////////////////////////////////////
/**
 请求服务器地址
 */
@property (nonatomic, copy) NSString *baseUrlPath;

/**
 请求路径
 */
@property (nonatomic, copy) NSString *urlPath;

/**
 请求参数
 */
@property (nonatomic, strong) __kindof NSMutableDictionary *paramDict;

/**
 上传数据
 */
@property (nonatomic, copy) AFConstructingBlock constructingBodyBlock;


/////////////////////////////////////////////////////////////////////////
/**
 进度
 */
@property (nonatomic, strong) NSProgress *progress;

/**
 返回数据 原始数据
 */
@property (nonatomic, strong) id responseObject;

/**
 返回数据 responseFormat:JSON
 */
@property (nonatomic, strong) NSDictionary *responseJsonDict;

/////////////////////////////////////////////////////////////////////////
/**
 错误
 */
@property (nonatomic, strong) NSError *error;

/**
 错误类型
 */
@property (nonatomic, assign) ResponseErrorType errorType;


/**
 需要通过代理方法时，初始化请求msg，并设置代理

 @param delegate HttpResponseDelegate
 @param urlPath 请求路径
 @param param 请求参数
 @param code 请求标识符
 @return 返回一个请求msg实例
 */
- (instancetype)initWithDelegate:(id<HttpResponseDelegate>)delegate
                         urlPath:(NSString *)urlPath
                       paramDict:(NSMutableDictionary *)param
                         cmdCode:(MsgCMDCode)code;

/**
 取消请求
 */
- (void)cancelRequest;

@end

@protocol HttpResponseDelegate <NSObject>

@optional

/**
 请求完成（有请求返回）后的回调方法 ！！！数据接收成功且数据解析正确

 @param receiveMsg HttpRequestMsg对象
 */
- (void)receiveDidFinished:(HttpRequestMsg *)receiveMsg;

/**
 请求失败（超时，网络未连接等错误）后的回调方法 ！！！数据解析错误等

 @param receiveMsg HttpRequestMsg对象
 */
- (void)receiveDidFailed:(HttpRequestMsg *)receiveMsg;

@end

