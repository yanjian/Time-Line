//
//  EventAlertsViewController.h
//  Time-Line
//
//  Created by IF on 14-10-15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventAlertsDelegate;

@interface EventAlertsViewController : UIViewController

@property (nonatomic,strong) id<EventAlertsDelegate> delegate;

@end

@protocol EventAlertsDelegate <NSObject>

-(void)eventsAlertTimeString:(NSString *) alertSt;

@end