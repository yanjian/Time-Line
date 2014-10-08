//
//  AnyEvent.h
//  Time-Line
//
//  Created by IF on 14-10-6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AnyEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * calendarAccount;
@property (nonatomic, retain) NSString * alerts;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * repeat;
@property (nonatomic, retain) NSString * coordinate;
@end
