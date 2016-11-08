//
//  ViewController.m
//  YBAFNetworking
//
//  Created by 尚往文化 on 16/11/8.
//  Copyright © 2016年 YBing. All rights reserved.
//

#import "ViewController.h"
#import "YBAFNCacheHttpTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /***************测试****************/
    /***************参数请根据项目中来设置，这里只是演示****************/
    [self test_get];
    
}

//get请求
- (void)test_get
{
    NSString *url = @"http://www.baidu.com";
    NSDictionary *params = @{@"i":@"1"};
    [YBAFNCacheHttpTool get:url params:params success:^(NSDictionary *obj) {
       //成功
    } failure:^(NSError *error) {
        //失败
    }];
}

//get带缓存的请求
- (void)test_get_cache
{
    NSString *url = @"http://www.baidu.com";
    NSDictionary *params = @{@"i":@"1"};
    [YBAFNCacheHttpTool get:url params:params cacheType:YBCacheTypeReturnCacheDataThenLoad success:^(NSDictionary *obj) {
        //成功
    } failure:^(NSError *error) {
        //失败
    }];
}

//post请求
- (void)test_post
{
    NSString *url = @"http://www.baidu.com";
    NSDictionary *params = @{@"i":@"1"};
    [YBAFNCacheHttpTool post:url params:params success:^(NSDictionary *obj) {
        //成功
    } failure:^(NSError *error) {
        //失败
    }];
}

//post请求带缓存
- (void)test_post_cache
{
    NSString *url = @"http://www.baidu.com";
    NSDictionary *params = @{@"i":@"1"};
    [YBAFNCacheHttpTool post:url params:params cacheType:YBCacheTypeReturnCacheDataThenLoad success:^(NSDictionary *obj) {
        //成功
    } failure:^(NSError *error) {
        //失败
    }];
}

//上传单张图片
- (void)test_upload_image
{
    UIImage *image = [UIImage imageNamed:@"1"];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [YBAFNCacheHttpTool uploadImageWithImage:data success:^(NSDictionary *obj) {
        //上传成功
    } failure:^(NSError *error) {
        //上传失败
    }];
}

//上传多张图片
- (void)test_upload_imageArr
{
    UIImage *image = [UIImage imageNamed:@"1"];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    NSArray *images = @[data, data];
    [YBAFNCacheHttpTool uploadImageArrayWithImages:images success:^(NSDictionary *obj) {
        //上传成功
    } failure:^(NSError *error) {
        //上传失败
    }];
}

@end
