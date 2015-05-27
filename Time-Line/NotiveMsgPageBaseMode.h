//
//  NotiveMsgPageBaseMode.h
//  Go2
//
//  Created by IF on 15/1/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface NotiveMsgPageBaseMode : BaseMode

@property (nonatomic, retain) NSArray *records;       //取到的消息
@property (nonatomic, retain) NSNumber *pageSize;     //每页显示的记录条数
@property (nonatomic, retain) NSNumber *pageNum;      //当前页码
@property (nonatomic, retain) NSNumber *totalPage;    //总页数
@property (nonatomic, retain) NSNumber *startIndex;   //每页开始记录的索引
@property (nonatomic, retain) NSNumber *totalRecords; //总记录条数
@end
