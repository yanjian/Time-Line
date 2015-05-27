//
//  GoogleCalendarData.m
//  Go2
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


- (void)encodeWithCoder:(NSCoder *)encode {
	[encode encodeObject:self.Id forKey:@"Id"];
	[encode encodeObject:self.summary forKey:@"summary"];
	[encode encodeObject:self.timeZone forKey:@"timeZone"];
	[encode encodeObject:self.backgroundColor forKey:@"backgroundColor"];
	[encode encodeObject:self.foregroundColor forKey:@"foregroundColor"];
	[encode encodeObject:self.accessRole forKey:@"accessRole"];
	[encode encodeObject:self.defaultRemindersDic forKey:@"defaultRemindersDic"];
	[encode encodeBool:self.isPrimary forKey:@"primary"];
	[encode encodeBool:self.isLocalAccount forKey:@"isLocalAccount"];
	[encode encodeBool:self.account forKey:@"account"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.Id = (NSString *)[decoder decodeObjectForKey:@"Id"];
		self.summary = (NSString *)[decoder decodeObjectForKey:@"summary"];
		self.timeZone = (NSString *)[decoder decodeObjectForKey:@"timeZone"];
		self.backgroundColor = (NSString *)[decoder decodeObjectForKey:@"backgroundColor"];
		self.foregroundColor = (NSString *)[decoder decodeObjectForKey:@"foregroundColor"];
		self.accessRole = (NSString *)[decoder decodeObjectForKey:@"accessRole"];
		self.defaultRemindersDic = (NSMutableDictionary *)[decoder decodeObjectForKey:@"defaultRemindersDic"];
		self.isPrimary = [decoder decodeBoolForKey:@"primary"];
		self.isLocalAccount = [decoder decodeBoolForKey:@"isLocalAccount"];
		self.account = (NSString *)[decoder decodeObjectForKey:@"account"];
	}
	return self;
}

- (NSDictionary *)dictionaryFromObject {
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
	[dic setObject:self.Id forKey:@"Id"];
	[dic setObject:self.summary forKey:@"summary"];
	[dic setObject:self.timeZone forKey:@"timeZone"];
	[dic setObject:self.backgroundColor forKey:@"backgroundColor"];
	[dic setObject:self.foregroundColor forKey:@"foregroundColor"];
	[dic setObject:self.accessRole forKey:@"accessRole"];
	[dic setObject:self.defaultRemindersDic forKey:@"defaultRemindersDic"];
	[dic setObject:self.account forKey:@"account"];
	return dic;
}

@end
