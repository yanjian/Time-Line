//
//  AllDayEventsViewController.h
//  Time-Line
//
//  Created by IF on 14-10-15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AllDayEventsDelegate;
@interface AllDayEventsViewController : UIViewController
@property (nonatomic,strong) id<AllDayEventsDelegate> delegate;
@end


@protocol AllDayEventsDelegate  <NSObject>

-(void)getAllDayEvent:(NSString *)timestr;

@end