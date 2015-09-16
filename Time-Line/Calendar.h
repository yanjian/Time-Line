//
//  Calendar.h
//  Go2
//
//  Created by IF on 15/8/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AT_Account, AnyEvent, Go2Account;

@interface Calendar : NSManagedObject

@property (nonatomic, copy)   NSString * account;
@property (nonatomic, copy)   NSString * backgroundColor;
@property (nonatomic, copy)   NSString * cid;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isNotification;
@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, copy)   NSString * summary;
@property (nonatomic, copy)   NSString * timeZone;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, copy)   NSString * baid;
@property (nonatomic, retain) NSSet    * anyEvent;
@property (nonatomic, retain) AT_Account * atAccount;
@property (nonatomic, retain) Go2Account * go2Account;

@end

@interface Calendar (CoreDataGeneratedAccessors)

- (void)addAnyEventObject:(AnyEvent *)value;
- (void)removeAnyEventObject:(AnyEvent *)value;
- (void)addAnyEvent:(NSSet *)values;
- (void)removeAnyEvent:(NSSet *)values;

@end
