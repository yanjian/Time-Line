//
//  Friend.h
//  Go2
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject



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


@property (nonatomic, assign, getter = isVip) BOOL vip;

+ (instancetype)friendWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
