//
//  t_Network.h
//  Go2
//
//  Created by IF on 14-9-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@interface t_Network : NSObject

//GET方式请求
+ (ASIHTTPRequest *)httpGet:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag;

+ (ASIHTTPRequest *)httpGet:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag userInfo:(NSDictionary *) dictionary;



//POST方式请求
+ (ASIFormDataRequest *)httpPostValue:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag;

//POST方式请求+userInfo信息
+ (ASIFormDataRequest *)httpPostValue:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag userInfo:(NSDictionary *) dictionary;
@end