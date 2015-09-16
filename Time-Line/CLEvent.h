//
//  CLEvent.h
//  Go2
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLEvent : BaseMode

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSMutableDictionary *evetndic;
@end
