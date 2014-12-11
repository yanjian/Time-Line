//
//  UserInfo.m
//  Time-Line
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (UserInfo *)currUserInfo
{
    static UserInfo *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

@end
