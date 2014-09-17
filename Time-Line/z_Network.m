//
//  z_Network.m
//  Time-Line
//
//  Created by IF on 14-9-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "z_Network.h"

@implementation z_Network

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
    NSEnumerator * enumeratorKey = [value keyEnumerator];
    NSString *urlString =[NSString stringWithFormat:@"%@?",url];
    NSArray *array=[enumeratorKey allObjects];
    for (int i=0;i<[array count];i++)
    {
        NSObject *object=[array objectAtIndex:i];
        NSString *key=[object description];
        if(i==[array count]-1)
        {
            urlString =[NSString stringWithFormat:@"%@%@=%@",urlString,key,[value valueForKey:key]];
        }
        else {
            urlString =[NSString stringWithFormat:@"%@%@=%@&",urlString,key,[value valueForKey:key]];
        }
    }
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"requestURL: %@",urlString);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:delegate];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"*/*"];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
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
    NSString *urlString=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIFormDataRequest*request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:delegate];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:20];
    [request setTag:tag];
    [request setPostValue:[value JSONString] forKey:@"json"];
    NSLog(@"requestURL: %@",urlString);
    NSLog(@"requestURL: %@",[request postBody]);
    
    return request;
}

@end