//
//  LocalCalendarData.h
//  Time-Line
//   同步本地服务器的对象
//  Created by IF on 14-10-9.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface LocalCalendarData : BaseMode<NSCoding>
@property (nonatomic,copy) NSString *Id;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *calendarName;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,copy) NSString *emailAccount;
@property (nonatomic,assign) BOOL isLocalAccount;
@end
