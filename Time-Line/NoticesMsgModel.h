//
//  NoticesMsgModel.h
//  Time-Line
//
//  Created by IF on 15/1/20.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface NoticesMsgModel : BaseMode


@property (nonatomic,  copy) NSNumber *Id;
@property (nonatomic,  copy) NSNumber *isRead;           // 1 己读     0 未读
@property (nonatomic,  copy) NSNumber *isReceive;        // 1 己接收    0 未返回
@property (nonatomic, retain) NSDictionary *message;
@property (nonatomic,  copy) NSString *time;
@property (nonatomic,  copy) NSNumber *type;       // 好友请求：1(requests) xx request to add you as a friend
                                                   //同意:2(notification)agree xx agree with your friend requests
                                                   //拒绝:3(notification)reject  xx refused your friend requests
                                                   //删除:4 delete； 没有消息，返回fid, fname
                                                   // 10 活动更新, 11 活动新增或邀请成员  31(message) xx: message
                                                   //32(notification)event update   -- New members  --Members of the exit   --event update

@end
