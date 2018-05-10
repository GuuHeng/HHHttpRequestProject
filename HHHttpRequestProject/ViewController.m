//
//  ViewController.m
//  HHHttpRequestProject
//
//  Created by Hu Heng on 2018/5/10.
//  Copyright © 2018年 Hu Heng. All rights reserved.
//

#import "ViewController.h"
#import "DemoApiService.h"
#import "BlockApiService.h"

@interface ViewController ()<DemoApiServiceDelegate>

@property (nonatomic, strong) DemoApiService *apiService;
@property (nonatomic, strong) BlockApiService *blockApiService;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.apiService beginGetDemoDataWithName:@"xiaoming"];
    
    [self.blockApiService beginGetBannerImages:^(NSArray<NSString *> * _Nullable images) {
        
        if (images && images.count > 0) {
            // do something
        } else {
            // do something
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DemoApiServiceDelegate

- (void)demoApiService:(DemoApiService *)demoApi
   completionIsSuccess:(BOOL)isSuccess
                  data:(NSArray<NSString *> *)dataImages
{
    // do something...
}

#pragma mark - getter

- (DemoApiService *)apiService {
    if (!_apiService) {
        _apiService = [[DemoApiService alloc] init];
        _apiService.delegate = self;
    }
    return _apiService;
}

- (BlockApiService *)blockApiService {
    if (!_blockApiService) {
        _blockApiService = [[BlockApiService alloc] init];
    }
    return _blockApiService;
}

@end
