//
//  FriendGroup.h
//  Time-Line
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendGroup : NSObject

@property (nonatomic, strong) NSString * Id;
@property (nonatomic, copy)   NSString * name;
@property (nonatomic, strong) NSArray  * friends;
@property (nonatomic, assign) NSInteger  online;

@property (nonatomic, assign, getter = isOpened) BOOL opened;

+ (instancetype)friendGroupWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
