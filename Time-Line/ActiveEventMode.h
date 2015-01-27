//
//  ActiveEventMode.h
//  Time-Line
//
//  Created by IF on 14/12/24.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveBaseInfoMode.h"
@interface ActiveEventMode : ActiveBaseInfoMode

@property (nonatomic,copy)     NSString       * location;
@property (nonatomic,copy)     NSString       * note;
@property (nonatomic,copy)     NSString       * coordinate;
@property (nonatomic,copy)     NSString       * eventVote;
@property (nonatomic,copy)     NSString       * veTime;
@property (nonatomic,retain)   NSArray        * time;
@property (nonatomic,retain)   NSArray        * member;
@property (nonatomic,retain)   NSArray        * etList;
@property (nonatomic,assign)   NSInteger        timeSize;
@property (nonatomic,copy)     NSString       * voteEndTime;
@property (nonatomic,retain)   NSArray        * evList;

@end
