//
//  UserInfo.h
//  Time-Line
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMode.h"
typedef enum {
	gender_woman = 0,
	gender_man = 1
} genderSex;


@interface UserInfo : BaseMode
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSArray *accountBinds;
@property (nonatomic, strong) NSString *authCode;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gRefreshToken;
@property (nonatomic, assign) genderSex gender;
@property (nonatomic, strong) NSString *googleToken;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *imgUrlSmall;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *registerTime;
@property (nonatomic, strong) NSString *tokenTime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, assign) UserLoginStatus loginStatus;//登陆状态
@property (nonatomic, assign) AccountType accountType;//登陆账号的类型

+ (instancetype)currUserInfo;
//将用户归档
+ (void)userInfoWithArchive:(UserInfo *)userInfo;

@end
