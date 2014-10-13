//
//  GoogleCalendarData.m
//  Time-Line
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "GoogleCalendarData.h"

@implementation GoogleCalendarData


//- (GoogleCalendarData *)copyWithZone:(NSZone *)zone{
//    GoogleCalendarData *newGoogleData=[[self class] allocWithZone:zone];
//    newGoogleData.Id=_Id;
//    newGoogleData.summary=_summary;
//    newGoogleData.timeZone=_timeZone;
//    newGoogleData.backgroundColor=_backgroundColor;
//    newGoogleData.foregroundColor=_foregroundColor;
//    newGoogleData.accessRole=_accessRole;
//    newGoogleData.defaultRemindersDic=_defaultRemindersDic;
//    return newGoogleData;
//}
//
//-(GoogleCalendarData *)mutableCopyWithZone:(NSZone *)zone{
//    GoogleCalendarData *newGoogleData=[[self class] allocWithZone:zone];
//    newGoogleData.Id=_Id;
//    newGoogleData.summary=_summary;
//    newGoogleData.timeZone=_timeZone;
//    newGoogleData.backgroundColor=_backgroundColor;
//    newGoogleData.foregroundColor=_foregroundColor;
//    newGoogleData.accessRole=_accessRole;
//    newGoogleData.defaultRemindersDic=_defaultRemindersDic;
//    return newGoogleData;
//}


- (void)encodeWithCoder:(NSCoder *)encode{
    [encode encodeObject:self.Id forKey:@"Id"];
    [encode encodeObject:self.summary forKey:@"summary"];
    [encode encodeObject:self.timeZone forKey:@"timeZone"];
    [encode encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [encode encodeObject:self.foregroundColor forKey:@"foregroundColor"];
    [encode encodeObject:self.accessRole forKey:@"accessRole"];
    [encode encodeObject:self.defaultRemindersDic forKey:@"defaultRemindersDic"];
}

- (id)initWithCoder:(NSCoder *)decoder{
    if (self=[super init]) {
        self.Id=(NSString *)[decoder decodeObjectForKey:@"Id"];
        self.summary =(NSString *)[decoder decodeObjectForKey:@"summary"];
        self.timeZone =(NSString *)[decoder decodeObjectForKey:@"timeZone"];
        self.backgroundColor =(NSString *)[decoder decodeObjectForKey:@"backgroundColor"];
        self.foregroundColor =(NSString *)[decoder decodeObjectForKey:@"foregroundColor"];
        self.accessRole =(NSString *)[decoder decodeObjectForKey:@"accessRole"];
        self.defaultRemindersDic =(NSMutableDictionary *)[decoder decodeObjectForKey:@"defaultRemindersDic"];
    }
    return  self;
}
@end
