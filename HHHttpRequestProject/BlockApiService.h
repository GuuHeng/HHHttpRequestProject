//
//  BlockApiService.h
//  HHHttpRequestProject
//
//  Created by Hu Heng on 2018/5/10.
//  Copyright © 2018年 Hu Heng. All rights reserved.
//

#import "DataApiService.h"

@interface BlockApiService : DataApiService

@property (nonatomic, strong) HttpRequestMsg *userInfoMsg;
@property (nonatomic, strong) HttpRequestMsg *bannerMsg;


/**
 获取个人信息

 @param userId 参数
 @param successBlock 成功回调
 */
- (void)beginGetUserInfoWithId:(NSString *)userId success:(void(^)(NSDictionary * _Nullable userInfoDict))successBlock;

- (void)beginGetBannerImages:(void(^)(NSArray <NSString *> * _Nullable images))successBlock;

@end
