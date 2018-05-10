//
//  BlockApiService.m
//  HHHttpRequestProject
//
//  Created by Hu Heng on 2018/5/10.
//  Copyright © 2018年 Hu Heng. All rights reserved.
//

#import "BlockApiService.h"

@implementation BlockApiService

#pragma mark -

- (void)beginGetUserInfoWithId:(NSString *)userId success:(void (^)(NSDictionary *))successBlock
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (userId) {
        [dict setObject:userId forKey:@"userId"];
    }
    
    self.userInfoMsg.paramDict = dict;
    
    [self startMsg:self.userInfoMsg success:^(HttpRequestMsg *msg) {
        
        // 在使用AFNetworking时，回调其实回到主线程的
        // 这就需要使用者自己自行调起异步处理耗时数据，再回到主线程进行UI的更新等
        NSDictionary *userDict = @{@"1": @"b"};
        
        // userinfo一般会转成model，建议异步转成model后，再主线程回调
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            // do something
            // dictionayr to model
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) {
                    successBlock(userDict);
                }
            });
        });
        
    } failure:^(HttpRequestMsg *msg) {
        
        successBlock(nil);
        
    }];
}

- (void)beginGetBannerImages:(void (^)(NSArray<NSString *> * _Nullable))successBlock
{
    [self startMsg:self.bannerMsg success:^(HttpRequestMsg *msg) {
        
        // 在使用AFNetworking时，回调其实回到主线程的
        // 这就需要使用者自己自行调起异步处理耗时数据，再回到主线程进行UI的更新等
        
        NSArray *images = @[@"1", @"2"];
        
        successBlock(images);
        
    } failure:^(HttpRequestMsg *msg) {
        
        successBlock(nil);
        
    }];
}

#pragma mark - getter

- (HttpRequestMsg *)bannerMsg {
    if (!_bannerMsg) {
        _bannerMsg = [[HttpRequestMsg alloc] init];
        _bannerMsg.baseUrlPath = @"https://www.demo.com";
        _bannerMsg.urlPath = @"/banner";
    }
    return _bannerMsg;
}

- (HttpRequestMsg *)userInfoMsg {
    if (!_userInfoMsg) {
        _userInfoMsg = [[HttpRequestMsg alloc] init];
        _userInfoMsg.baseUrlPath = @"https://www.demo.com";
        _userInfoMsg.urlPath = @"/userinfo";
    }
    return _userInfoMsg;
}

@end
