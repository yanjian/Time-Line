//
//  Calendar.h
//  Go2
//
//  Created by IF on 14/10/21.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AT_Account, AnyEvent;

@interface Calendar : NSManagedObject

@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *backgroundColor;
@property (nonatomic, retain) NSString *cid;
@property (nonatomic, retain) NSNumber *isDefault;
@property (nonatomic, retain) NSNumber *isNotification;
@property (nonatomic, retain) NSNumber *isVisible;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *timeZone;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSSet *anyEvent;
@property (nonatomic, retain) AT_Account *atAccount;
@end

@interface Calendar (CoreDataGeneratedAccessors)

- (void)addAnyEventObject:(AnyEvent *)value;
- (void)removeAnyEventObject:(AnyEvent *)value;
- (void)addAnyEvent:(NSSet *)values;
- (void)removeAnyEvent:(NSSet *)values;

@end
