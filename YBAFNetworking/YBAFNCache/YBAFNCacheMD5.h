//
//  MyMD5.h
//  GoodLectures
//
//  Created by yangshangqing on 11-10-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YBAFNCacheMD5 : NSObject

/**
 *  md5加密
 *
 *  @param inPutText 需要加密的字符串
 *
 *  @return 加密好的字符串
 */
+ (NSString *)md5:(NSString *)inPutText;

@end
