//
//  AT_Account.h
//  Time-Line
//
//  Created by IF on 14/10/21.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Calendar;

@interface AT_Account : NSManagedObject

@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSNumber *accountType;
@property (nonatomic, retain) NSSet *ca;
@end

@interface AT_Account (CoreDataGeneratedAccessors)

- (void)addCaObject:(Calendar *)value;
- (void)removeCaObject:(Calendar *)value;
- (void)addCa:(NSSet *)values;
- (void)removeCa:(NSSet *)values;

@end
