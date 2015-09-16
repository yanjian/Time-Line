//
//  t_Network.m
//  Go2
//
//  Created by IF on 14-9-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "t_Network.h"
#import "ASIDownloadCache.h"
@implementation t_Network

/**
 *	@brief	HTTP协议GET方式请求数据
 *
 *	@param 	value 	字典型传输数据
 *	@param 	url 	访问地址
 *	@param 	delegate 	代理
 *
 *	@return	返回ASI类型
 */
+ (ASIHTTPRequest *)httpGet:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag
{
    ASIHTTPRequest *request=[t_Network httpGet:value Url:url Delegate:delegate Tag:tag userInfo:nil];
    return  request;
}

+ (ASIHTTPRequest *)httpGet:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag userInfo:(NSDictionary *) dictionary{
    NSEnumerator * enumeratorKey = [value keyEnumerator];
    NSRange rang = [url rangeOfString:@"?"];
    NSString *urlString = url ;
    if (rang.location == NSNotFound) {
        if (value) {
            urlString =[NSString stringWithFormat:@"%@?",url];
        }
    }
    NSArray *array=[enumeratorKey allObjects];
    for (NSUInteger i=0 ; i< array.count ; i++)
    {
        NSObject *object=[array objectAtIndex:i];
        NSString *key=[object description];
        if(i == [array count] -1)
        {
            urlString = [NSString stringWithFormat:@"%@%@=%@",urlString,key,[value valueForKey:key]];
        } else {
            urlString = [NSString stringWithFormat:@"%@%@=%@&",urlString,key,[value valueForKey:key]];
        }
    }
    NSLog(@"requestURL: %@",urlString);
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:delegate];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"*/*"];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    if (dictionary) {
         [request setUserInfo:dictionary];
    }
    [request setTag:tag];
    return  request;


}


/**
 *	@brief	HTTP协议POST方式请求数据
 *
 *	@param 	value 	字典型传输数据
 *	@param 	url 	访问地址
 *	@param 	delegate 	代理
 *
 *	@return	返回ASI类型
 */
+ (ASIFormDataRequest *)httpPostValue:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag
{
    ASIFormDataRequest *request= [t_Network httpPostValue:value Url:url Delegate:delegate Tag:tag userInfo:nil];
    return request;
}


/**
 *	@brief	HTTP协议POST方式请求数据
 *
 *	@param 	value 	字典型传输数据
 *	@param 	url 	访问地址
 *	@param 	delegate 	代理
 *  @param 	dictionary  附带信息
 *	@return	返回ASI类型
 */
+ (ASIFormDataRequest *)httpPostValue:(NSMutableDictionary *)value Url:(NSString *)url Delegate:(id)delegate Tag:(NSInteger)tag userInfo:(NSDictionary *) dictionary{
    NSArray  *allKeyArr;
    if (value) {
        allKeyArr=[value allKeys];
    }
    
    NSString *urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:delegate];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:20];
    [request setTag:tag];
    if (dictionary) {
        [request setUserInfo:dictionary];
    }
    if (value) {
        for (NSUInteger i=0; i<allKeyArr.count; i++) {
            NSString *key=allKeyArr[i];
            [request setPostValue:[value objectForKey:key] forKey:key];
        }
    }
    NSLog(@"requestURL: %@",urlString);
    NSLog(@"requestBody: %@",[request postBody]);
    return request;
}


@end