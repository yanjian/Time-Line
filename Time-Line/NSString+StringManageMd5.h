//
//  NSString+StringManageMd5.h
//  Time-Line
//
//  Created by IF on 14-10-6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (StringManageMd5)
- (NSString *)md5;
- (NSString *)encode;
- (NSString *)decode;
- (id)object;
@end
