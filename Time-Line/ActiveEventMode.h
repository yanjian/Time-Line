//
//  ActiveEventMode.h
//  Time-Line
//
//  Created by IF on 14/12/24.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMode.h"
@interface ActiveEventMode : BaseMode

@property (nonatomic,copy)     NSString       * Id;//
@property (nonatomic,copy)     NSString       * location;
@property (nonatomic,copy)     NSString       * note;//
@property (nonatomic,copy)     NSString       * coordinate;
@property (nonatomic,copy)     NSString       * eventVote;
@property (nonatomic,assign)   NSString       * type;//
@property (nonatomic,copy)     NSString       * title;//
@property (nonatomic,copy)     NSString       * veTime;
@property (nonatomic,retain)   NSArray        * time;//
@property (nonatomic,retain)   NSArray        * member;//
@property (nonatomic,retain)   NSDictionary   * create;//
@property (nonatomic,copy)     NSString       * addTime;//
@property (nonatomic,copy)     NSString       * status;//
@property (nonatomic,copy)     NSString       * createTime;//
@property (nonatomic,retain)   NSArray        * etList;//
@property (nonatomic,copy)     NSString       * imgUrl;//
@property (nonatomic,assign)   NSInteger        timeSize;//
@property (nonatomic,copy)     NSString       * voteEndTime;//
@property (nonatomic,retain)   NSArray        * evList;

@end
