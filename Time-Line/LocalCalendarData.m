//
//  LocalCalendarData.m
//  Go2
//
//  Created by IF on 14-10-9.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LocalCalendarData.h"

@implementation LocalCalendarData


- (void)encodeWithCoder:(NSCoder *)encode {
	[encode encodeObject:self.Id forKey:@"Id"];
	[encode encodeObject:self.uid forKey:@"uid"];
	[encode encodeObject:self.calendarName forKey:@"calendarName"];
	[encode encodeObject:self.color forKey:@"color"];
	[encode encodeObject:self.emailAccount forKey:@"emailAccount"];
	[encode encodeBool:self.isLocalAccount forKey:@"isLocalAccount"];
}

- (id)initWithCoder:(NSCoder *)decode {
	if (self = [super init]) {
		self.Id = (NSString *)[decode decodeObjectForKey:@"Id"];
		self.uid = (NSString *)[decode decodeObjectForKey:@"uid"];
		self.calendarName = (NSString *)[decode decodeObjectForKey:@"calendarName"];
		self.color = (NSString *)[decode decodeObjectForKey:@"color"];
		self.emailAccount = (NSString *)[decode decodeObjectForKey:@"emailAccount"];
		self.isLocalAccount = [decode decodeBoolForKey:@"isLocalAccount"];
	}
	return self;
}

@end
