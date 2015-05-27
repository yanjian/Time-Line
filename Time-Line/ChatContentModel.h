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
@property (strong , nonatomic) NSString * text;
@property (strong , nonatomic) NSString * time;
@property (strong , nonatomic) NSString * type;
@property (strong , nonatomic) NSString * uid;
@property (strong , nonatomic) NSString * username;
@property (assign , nonatomic) NSNumber * unreadMessage;

@end
