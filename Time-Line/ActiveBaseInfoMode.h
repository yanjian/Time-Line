//
//  ActiveBaseInfoMode.h
//  Time-Line
//
//  Created by IF on 15/1/22.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface ActiveBaseInfoMode : BaseMode
@property (nonatomic,copy)     NSString       * Id;
@property (nonatomic,copy)     NSString       * title; //事件标题
@property (nonatomic,retain)   NSString       * create;//创建者
@property (nonatomic,copy)     NSString       * addTime;
@property (nonatomic,copy)     NSString       * status; //事件状态 0 upcoming（votiong）1.to be confirm  2.confirmed   3.past
@property (nonatomic,copy)     NSString       * createTime; //创建时间
@property (nonatomic,copy)     NSString       * imgUrl;
@property (nonatomic,assign)   NSString       * type; //是否允许添加时间 1.固定 ----- 2. 投票
@end
