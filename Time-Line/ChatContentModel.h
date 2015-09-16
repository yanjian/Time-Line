//
//  ChatContentModel.h
//  Go2
//
//  Created by IF on 15/3/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, UnreadMessage){
    UNREADMESSAGE_NO = 0,
    UNREADMESSAGE_YES = 1
};

@interface ChatContentModel : NSManagedObject

@property (strong , nonatomic) NSString * eid;
@property (strong , nonatomic) NSString * imgBig;
@property (strong , nonatomic) NSString * imgSmall;
@property (strong , nonatomic) NSString * text;//不需要啦
@property (strong , nonatomic) NSString * time;//不需要啦
@property (strong , nonatomic) NSString * type;
@property (strong , nonatomic) NSString * uid;
@property (strong , nonatomic) NSString * username;
@property (assign , nonatomic) NSNumber * unreadMessage;

//跟换接口新增的属性
@property (strong , nonatomic) NSNumber *  msg_type;
@property (strong , nonatomic) NSString *  voiceAac;

//{"content":"一个陌生女人的来信","createTime":"2015-09-11 10:45:18","type":15,"msg_type":0,"uid":"f81a36f7-130f-4e07-9387-627ffb5c20d8","eid":"57a01f36-d5d7-4bcc-866a-5416325895ad","username":"gttest1"}
@end
