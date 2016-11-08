 //
//  YBHttp.m
//  Wanyingjinrong
//
//  Created by Jason on 15/11/17.
//  Copyright © 2015年 www.jizhan.com. All rights reserved.
//

#import "YBAFNCacheHttpTool.h"
#import <objc/runtime.h>
#import "YBAFNCacheConstant.h"

@implementation YBAFNCache

@end

static char *NSErrorStatusCodeKey = "NSErrorStatusCodeKey";

@implementation NSError (YBHttp)

- (void)setStatusCode:(NSInteger)statusCode
{
    objc_setAssociatedObject(self, NSErrorStatusCodeKey, @(statusCode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)statusCode
{
    return [objc_getAssociatedObject(self, NSErrorStatusCodeKey) integerValue];
}

@end


@implementation YBAFNCacheHttpTool

//错误处理
+ (void)errorHandle:(NSURLSessionDataTask * _Nullable)task error:(NSError * _Nonnull)error failure:(void (^)(NSError *))failure
{
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSInteger statusCode = response.statusCode;
    
    error.statusCode = statusCode;
    
    if (statusCode == 401) {//密码错误
        
    } else if (statusCode == 0) {//没有网络
        
    } else if (statusCode == 500) {//参数错误
        
    } else if (statusCode == 404) {
        
    } else if (statusCode == 400) {
        
    }
    
    if (failure) {
        failure(error);
    }
}

+ (NSString *)fileName:(NSString *)url params:(NSDictionary *)params
{
    NSMutableString *mStr = [NSMutableString stringWithString:url];
    if (params != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [mStr appendString:str];
    }
    return mStr;
}

+ (AFHTTPSessionManager *)sessionManager
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    //设置接受的类型
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", nil];
    //设置请求超时
    sessionManager.requestSerializer.timeoutInterval = 30;
    //设置请求头  根据项目设置
    [sessionManager.requestSerializer setValue:@"ajSgfASewSsEhGdAsFf" forHTTPHeaderField:@"ticket"];
    return sessionManager;
}

+ (YBAFNCache *)getCache:(YBCacheType)cacheType url:(NSString *)url params:(NSDictionary *)params success:(void (^)(NSDictionary *))success
{
    //缓存数据的文件名
    NSString *fileName = [self fileName:url params:params];
    NSData *data = [YBAFNCacheTool getCacheFileName:fileName];
    
    YBAFNCache *cache = [[YBAFNCache alloc] init];
    cache.fileName = fileName;
    
    if (data.length) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (cacheType == YBCacheTypeReloadIgnoringLocalCacheData) {//忽略缓存，重新请求
            
        } else if (cacheType == YBCacheTypeReturnCacheDataDontLoad) {//有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
            
        } else if (cacheType == YBCacheTypeReturnCacheDataElseLoad) {//有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
            if (success) {
                success(dict);
            }
            cache.result = YES;
            
        } else if (cacheType == YBCacheTypeReturnCacheDataThenLoad) {///有缓存就先返回缓存，同步请求数据
            if (success) {
                success(dict);
            }
        } else if (cacheType == YBCacheTypeReturnCacheDataExpireThenLoad) {//有缓存 判断是否过期了没有 没有就返回缓存
            //判断是否过期
            if (![YBAFNCacheTool isExpire:fileName]) {
                if (success) {
                    success(dict);
                }
                cache.result = YES;
            }
        }
    }
    return cache;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params cacheType:(YBCacheType)cacheType success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [self sessionManager];
    
    NSString *httpStr = [[kAPI_URL stringByAppendingString:url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //缓存数据的文件名 data
    YBAFNCache *cache = [self getCache:cacheType url:url params:params success:success];
    NSString *fileName = cache.fileName;
    if (cache.result) return;
    YBWeakSelf
    [sessionManager GET:httpStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        YBLog(@"%lld", downloadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            
            //缓存数据
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            [YBAFNCacheTool cacheForData:data fileName:fileName];
            
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf errorHandle:task error:error failure:failure];
    }];
}

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    [self get:url params:params cacheType:YBCacheTypeReloadIgnoringLocalCacheData success:success failure:failure];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params cacheType:(YBCacheType)cacheType success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [self sessionManager];
    
    NSString *httpStr = [[kAPI_URL stringByAppendingString:url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //缓存数据的文件名 data
    YBAFNCache *cache = [self getCache:cacheType url:url params:params success:success];
    NSString *fileName = cache.fileName;
    if (cache.result) return;
    
    YBWeakSelf
    [sessionManager POST:httpStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            //缓存数据
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            [YBAFNCacheTool cacheForData:data fileName:fileName];
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf errorHandle:task error:error failure:failure];
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    [self post:url params:params cacheType:YBCacheTypeReloadIgnoringLocalCacheData success:success failure:failure];
}

+ (void)uploadImageWithImage:(NSData *)image success:(void (^)(NSDictionary *obj))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [self sessionManager];
    [sessionManager.requestSerializer setValue:@"image/jpg" forHTTPHeaderField:@"Content-Type"];
    NSString *httpStr = [[kAPI_URL stringByAppendingString:@"pic/fileupload"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    YBWeakSelf
    [sessionManager POST:httpStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //upfile 是参数名 根据项目修改
        [formData appendPartWithFileData:image name:@"upfile" fileName:[NSString stringWithFormat:@"%.0f.jpg", [[NSDate date] timeIntervalSince1970]] mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf errorHandle:task error:error failure:failure];
    }];
}

+ (void)uploadImageArrayWithImages:(NSArray<NSData *> *)images success:(void (^)(NSDictionary *obj))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *sessionManager = [self sessionManager];
    [sessionManager.requestSerializer setValue:@"image/jpg" forHTTPHeaderField:@"Content-Type"];
    NSString *httpStr = [[kAPI_URL stringByAppendingString:@"pic/fileuploadArr"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    YBWeakSelf
    [sessionManager POST:httpStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [images enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //upfiles 是参数名 根据项目修改
            [formData appendPartWithFileData:obj name:@"upfiles" fileName:[NSString stringWithFormat:@"%.0f.jpg", [[NSDate date] timeIntervalSince1970]] mimeType:@"image/jpg"];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            [weakSelf errorHandle:task error:error failure:failure];
        }
    }];
}

@end
