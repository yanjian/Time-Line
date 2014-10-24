//
//  GoogleEventMode.m
//  Time-Line
//
//  Created by IF on 14-9-30.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "GoogleEventMode.h"

@implementation GoogleEventMode



- (void)encodeWithCoder:(NSCoder *)encode{
    [encode encodeObject:self.Id forKey:@"Id"];
    [encode encodeObject:self.created forKey:@"created"];
    [encode encodeObject:self.updated forKey:@"updated"];
    [encode encodeObject:self.summary forKey:@"summary"];
    [encode encodeObject:self.description forKey:@"description"];
    [encode encodeObject:self.location forKey:@"location"];
    [encode encodeObject:self.creator forKey:@"creator"];
    [encode encodeObject:self.organizer forKey:@"organizer"];
    [encode encodeObject:self.startTime forKey:@"startTime"];
    [encode encodeObject:self.endTime forKey:@"endTime"];
    [encode encodeObject:self.reminders forKey:@"reminders"];
    
}
- (id)initWithCoder:(NSCoder *)decoder{
    if (self=[super init]) {
        self.Id=(NSString *)[decoder decodeObjectForKey:@"Id"];
        self.created =(NSDate *)[decoder decodeObjectForKey:@"created"];
        self.updated =(NSDate *)[decoder decodeObjectForKey:@"updated"];
        self.summary =(NSString *)[decoder decodeObjectForKey:@"summary"];
        self.description =(NSString *)[decoder decodeObjectForKey:@"description"];
        self.location =(NSString *)[decoder decodeObjectForKey:@"location"];
        self.creator =(NSDictionary *)[decoder decodeObjectForKey:@"creator"];
        self.organizer =(NSString *)[decoder decodeObjectForKey:@"organizer"];
        self.startTime =(NSDate *)[decoder decodeObjectForKey:@"startTime"];
        self.endTime =(NSDate *)[decoder decodeObjectForKey:@"endTime"];
        self.reminders =(NSDictionary *)[decoder decodeObjectForKey:@"reminders"];
       
    }
    return  self;
}
@end
