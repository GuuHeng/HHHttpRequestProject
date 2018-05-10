//
//  DemoApiService.h
//  HHHttpRequestProject
//
//  Created by Hu Heng on 2018/5/10.
//  Copyright © 2018年 Hu Heng. All rights reserved.
//

#import "DataApiService.h"

@protocol DemoApiServiceDelegate;

@interface DemoApiService : DataApiService

@property (nonatomic, strong, nonnull) HttpRequestMsg *demoMsg;

@property (nonatomic, weak) id <DemoApiServiceDelegate> delegate;

- (void)beginGetDemoDataWithName:(NSString * _Nullable)name;

@end

@protocol DemoApiServiceDelegate <NSObject>

- (void)demoApiService:(DemoApiService *)demoApi
   completionIsSuccess:(BOOL)isSuccess
                  data:(NSArray<NSString *> *)dataImages;

@end
