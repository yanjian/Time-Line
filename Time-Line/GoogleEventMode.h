//
//  GoogleEventMode.h
//  Time-Line
//
//  Created by IF on 14-9-30.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleEventMode : NSObject
@property (nonatomic,copy) NSString * Id;
@property (nonatomic,retain) NSDate * created;
@property (nonatomic,retain) NSDate * updated;
@property (nonatomic,copy) NSString * summary;
@property (nonatomic,copy) NSString * description;
@property (nonatomic,copy) NSString * location;
@property (nonatomic,retain) NSDictionary * creator;
@property (nonatomic,copy) NSString * organizer;
@property (nonatomic,copy) NSDate * startTime;
@property (nonatomic,copy) NSDate * endTime;
@property (nonatomic,copy) NSDictionary * reminders;
@end
