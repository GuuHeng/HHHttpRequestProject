//
//  DemoApiService.m
//  HHHttpRequestProject
//
//  Created by Hu Heng on 2018/5/10.
//  Copyright © 2018年 Hu Heng. All rights reserved.
//

#import "DemoApiService.h"

@implementation DemoApiService

- (void)beginGetDemoDataWithName:(NSString *)name
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (name) {
        [dict setObject:name forKey:@"name"];
    }
    self.demoMsg = [[HttpRequestMsg alloc] initWithDelegate:self
                                                    urlPath:@"/demoApi"
                                                  paramDict:dict];
    [self.httpControl sendRequestMsg:self.demoMsg];
}

- (void)receiveDidFinished:(HttpRequestMsg *)receiveMsg
{
    // 在使用AFNetworking时，回调其实回到主线程的
    // 这就需要使用者自己自行调起异步处理耗时数据，再回到主线程进行UI的更新等
    
    __weak typeof(DemoApiService) *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 请求回调的处理...
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(demoApiService:completionIsSuccess:data:)]) {
                [weakSelf.delegate demoApiService:self completionIsSuccess:YES data:nil];
            }
            
        });
    });
}

-(void)receiveDidFailed:(HttpRequestMsg *)receiveMsg
{
    if (_delegate && [_delegate respondsToSelector:@selector(demoApiService:completionIsSuccess:data:)]) {
        [_delegate demoApiService:self completionIsSuccess:YES data:nil];
    }
}

@end
