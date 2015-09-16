//
//  Go2Account.h
//  Go2
//
//  Created by IF on 15/8/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Calendar;

@interface Go2Account : NSManagedObject

@property (nonatomic, copy) NSString * account;
@property (nonatomic, copy) NSString * accountId;
@property (nonatomic, copy) NSString * aId;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet    * ca;

@end

@interface Go2Account (CoreDataGeneratedAccessors)

- (void)addCaObject:(Calendar *)value;
- (void)removeCaObject:(Calendar *)value;
- (void)addCa:(NSSet *)values;
- (void)removeCa:(NSSet *)values;

@end
