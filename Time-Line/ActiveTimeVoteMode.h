//
//  ActiveTimeVoteMode.h
//  Time-Line
//
//  Created by IF on 15/4/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface ActiveTimeVoteMode : BaseMode

@property (copy,nonatomic) NSString * allDay ;
@property (copy,nonatomic) NSString * eid ;
@property (copy,nonatomic) NSString * endTime ;
@property (copy,nonatomic) NSString * finalTime ; //1.默认， 2 表示时间确定
@property (copy,nonatomic) NSString * Id ;
@property (copy,nonatomic) NSString * startTime;
@end
