//
//  LocalCalendarData.m
//  Time-Line
//
//  Created by IF on 14-10-9.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LocalCalendarData.h"

@implementation LocalCalendarData


- (void)encodeWithCoder:(NSCoder *)encode{
    [encode encodeObject:self.Id forKey:@"Id"];
    [encode encodeObject:self.uid forKey:@"uid"];
    [encode encodeObject:self.calendarName forKey:@"calendarName"];
    [encode encodeObject:self.color forKey:@"color"];
}
- (id)initWithCoder:(NSCoder *)decode{
    if (self=[super init]) {
        self.Id=(NSString *)[decode decodeObjectForKey:@"Id"];
        self.uid=(NSString *)[decode decodeObjectForKey:@"uid"];
        self.calendarName=(NSString *)[decode decodeObjectForKey:@"calendarName"];
        self.color=(NSString *)[decode decodeObjectForKey:@"color"];
    }
    return self;
}
@end
