//
//  HttpRequestMsg.m
//  HHHttpRequest
//
//  Created by HuHeng on 2017/4/24.
//  Copyright © 2017年 Hu Heng. All rights reserved.
//

#import "HttpRequestMsg.h"
#import "HttpRequestControl.h"

@implementation HttpRequestMsg

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setup];
        
    }
    return self;
}

- (void) setup
{
    self.baseUrlPath = @"";
    self.requestMethod = RequestMethodPOST;
    self.responseFormat = ResponseFormatTypeJSON;
}

- (instancetype)initWithDelegate:(id<HttpResponseDelegate>)delegate
                         urlPath:(NSString *)urlPath
                       paramDict:(NSMutableDictionary *)param
//                         code:(NSString *)code
{
    self = [super init];
    if (self) {
        [self setup];
        self.delegate = delegate;
        self.urlPath = urlPath;
        self.paramDict = param;
//        self.requestCode = code;
    }
    return self;
}

- (void)cancelRequest
{
    _delegate = nil;
    [[HttpRequestControl sharedInstance] cancelRequestMsg:self];
}

@end
