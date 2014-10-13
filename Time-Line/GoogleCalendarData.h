//
//  GoogleCalendarData.h
//  Time-Line
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMode.h"

@interface GoogleCalendarData : BaseMode<NSCoding> //<NSCopying,NSMutableCopying>
@property (nonatomic,copy) NSString *Id;
@property (nonatomic,copy) NSString *summary;
@property (nonatomic,copy) NSString *timeZone;
@property (nonatomic,copy) NSString *backgroundColor;
@property (nonatomic,copy) NSString *foregroundColor;
@property (nonatomic,copy) NSString *accessRole;
@property (nonatomic,retain) NSMutableDictionary *defaultRemindersDic;
@end
