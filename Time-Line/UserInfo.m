//
//  UserInfo.m
//  Time-Line
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "UserInfo.h"

#define ID                @"id"
#define ACCOUNTBINDS      @"accountBinds"
#define AUTHCODE          @"authCode"
#define EMAIL             @"email"
#define GREFRESHTOKEN     @"gRefreshToken"
#define GENDER            @"gender"
#define GOOGLETOKEN       @"googleToken"
#define IMGURL            @"imgUrl"
#define IMGURLSMALL       @"imgUrlSmall"
#define NICKNAME          @"nickName"
#define PWD               @"password"
#define PHONE             @"phone"
#define REGISTERTIME      @"registerTime"
#define TOKENTIME         @"tokenTime"
#define TYPE              @"type"
#define USERNAME          @"username"
#define LOGINSTATUS       @"loginStatus"
#define ACCOUNTTYPE      @"accountType"

static UserInfo *sharedAccountManagerInstance = nil;

@interface UserInfo ()
+(UserInfo *) initUserInfoWithUserDefault;
@end


@implementation UserInfo

+ (UserInfo *)currUserInfo
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [UserInfo initUserInfoWithUserDefault] ;
    });
    return sharedAccountManagerInstance;
}

+(UserInfo *) initUserInfoWithUserDefault{
    NSData * userData = [USER_DEFAULT objectForKey:CURRENTUSERINFO];
    UserInfo * userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    if (!userInfo) {
        userInfo = [UserInfo new];
    }
    return userInfo;
}
//将用户归档
+(void)userInfoWithArchive:(UserInfo *) userInfo {
    if(userInfo){
     [USER_DEFAULT removeObjectForKey:CURRENTUSERINFO];//先移除当前的用户
     NSData * userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
     [USER_DEFAULT setObject:userInfoData forKey:CURRENTUSERINFO];
     [USER_DEFAULT synchronize];
    }
}


-(void)setImgUrl:(NSString *)imgUrl{
    if (imgUrl) {
        _imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
}

-(void)setImgUrlSmall:(NSString *)imgUrlSmall{
    if (imgUrlSmall) {
        _imgUrlSmall = [imgUrlSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
}

- (instancetype)initWithCoder:(NSCoder *) deCoder
{
    self = [super init];
    if (self) {
        self.Id = [deCoder decodeObjectForKey:ID];
        self.accountBinds = (NSArray *) [deCoder decodeObjectForKey:ACCOUNTBINDS];
        self.authCode = [deCoder decodeObjectForKey:AUTHCODE];
        self.email = [deCoder decodeObjectForKey:EMAIL] ;
        self.gRefreshToken = [deCoder decodeObjectForKey:GREFRESHTOKEN];
        self.gender = [[deCoder decodeObjectForKey:GENDER] integerValue];
        self.googleToken = [deCoder decodeObjectForKey:GOOGLETOKEN] ;
        self.imgUrl = [deCoder decodeObjectForKey:IMGURL] ;
        self.imgUrlSmall = [deCoder decodeObjectForKey:IMGURLSMALL] ;
        self.nickname = [deCoder decodeObjectForKey:NICKNAME] ;
        self.password = [deCoder decodeObjectForKey:PWD] ;
        self.phone = [deCoder decodeObjectForKey:PHONE] ;
        self.registerTime = [deCoder decodeObjectForKey:REGISTERTIME] ;
        self.tokenTime = [deCoder decodeObjectForKey: TOKENTIME] ;
        self.type = [deCoder decodeObjectForKey:TYPE] ;
        self.username = [deCoder decodeObjectForKey:USERNAME] ;
        self.loginStatus = [[deCoder decodeObjectForKey:LOGINSTATUS] integerValue];
        self.accountType = [[deCoder decodeObjectForKey:ACCOUNTTYPE] integerValue] ;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *) enCoder
{
    [enCoder encodeObject:self.Id forKey:ID];
    [enCoder encodeObject:self.accountBinds forKey:ACCOUNTBINDS];
    [enCoder encodeObject:self.authCode forKey:AUTHCODE];
    [enCoder encodeObject:self.email forKey:EMAIL];
    [enCoder encodeObject:self.gRefreshToken forKey:GREFRESHTOKEN];
    [enCoder encodeObject:@(self.gender) forKey:GENDER];
    [enCoder encodeObject:self.googleToken forKey:GOOGLETOKEN];
    [enCoder encodeObject:self.imgUrl forKey:IMGURL];
    [enCoder encodeObject:self.imgUrlSmall forKey:IMGURLSMALL];
    [enCoder encodeObject:self.nickname forKey:NICKNAME];
    [enCoder encodeObject:self.password forKey:PWD];
    [enCoder encodeObject:self.phone forKey:PHONE];
    [enCoder encodeObject:self.registerTime forKey:REGISTERTIME];
    [enCoder encodeObject:self.tokenTime forKey:TOKENTIME];
    [enCoder encodeObject:self.type forKey:TYPE];
    [enCoder encodeObject:self.username forKey:USERNAME];
    [enCoder encodeObject:@(self.loginStatus) forKey:LOGINSTATUS];
    [enCoder encodeObject:@(self.accountType) forKey:ACCOUNTTYPE];
}

@end
