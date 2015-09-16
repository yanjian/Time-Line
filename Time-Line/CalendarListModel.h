//
//  CalendarListModel.h
//  Go2
//
//  Created by IF on 15/8/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMode.h"

@interface CalendarListModel : NSManagedObject

@property (nonatomic,copy) NSString * cId    ;
@property (nonatomic,copy) NSString * baid  ;
@property (nonatomic,copy) NSString * color ;
@property (nonatomic,copy) NSString * name  ;
@property (nonatomic, retain) NSNumber *isDefault; //日历是否为默认日历
@property (nonatomic, retain) NSNumber *isNotification;//日历下面的事件是否通知
@property (nonatomic, retain) NSNumber *isVisible;//日历下面的事件是否显示
@property (nonatomic, assign) NSNumber * isLocalAccount;

@end
