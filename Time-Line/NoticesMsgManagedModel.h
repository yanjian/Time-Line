//
//  NoticesMsgManagedModel.h
//  Go2
//
//  Created by IF on 15/5/21.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NoticesMsgManagedModel : NSManagedObject
@property (nonatomic,  copy) NSString * nId;
@property (nonatomic,  copy) NSNumber * isRead;           // 1 己读     0 未读
@property (nonatomic,  copy) NSNumber * isReceive;        // 1 己接收    0 未返回
@property (nonatomic,  copy) NSString * message;
@property (nonatomic,  copy) NSString * time;
@property (nonatomic,  copy) NSNumber * type;
@property (nonatomic,  copy) NSString * uid;

@end
