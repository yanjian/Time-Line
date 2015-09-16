//
//  Friend.h
//  Go2
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMode.h"
@interface Friend : BaseMode

//{"id":"0a447625-eadd-4c3d-a0ba-e0b3a7f0b60e","username":"gttest2","phone":"13800138003","img":"/images/users/e/4/0a447625-eadd-4c3d-a0ba-e0b3a7f0b60e.png","thumbnail":"/images/users/e/4/100/0a447625-eadd-4c3d-a0ba-e0b3a7f0b60e.png","gender":0,"createTime":"2015-08-11 17:42:40","lastLoginTime":"2015-08-27 17:50:37"}

@property (nonatomic, copy)  NSString *Id;
@property (nonatomic, copy)  NSString *icon;
@property (nonatomic, copy)  NSString *alias;
@property (nonatomic, copy)  NSString *username;
@property (nonatomic, copy)  NSString *email;
@property (nonatomic, copy)  NSString *nickname;
@property (nonatomic, copy)  NSString *gender;
@property (nonatomic, copy)  NSString *imgBig;
@property (nonatomic, copy)  NSString *imgSmall;

@property (nonatomic, copy)  NSString *fid;
@property (nonatomic, copy)  NSString *fstatus;
@property (nonatomic, copy)  NSString *tid;

//更换接口添加的--------start-----------
@property (nonatomic, copy)  NSString *phone;
@property (nonatomic, copy)  NSString *img ;
@property (nonatomic, copy)  NSString *thumbnail;
@property (nonatomic, copy)  NSString *createTime;
@property (nonatomic, copy)  NSString *lastLoginTime;
//--------------------end-------------


@property (nonatomic, assign, getter = isVip) BOOL vip;

+ (instancetype)friendWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
