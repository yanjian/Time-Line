//
//  EventAlertsViewController.h
//  Go2
//
//  Created by IF on 14-10-15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventAlertsDelegate;

@interface EventAlertsViewController : UIViewController

@property (nonatomic, strong) id <EventAlertsDelegate> delegate;
@property (nonatomic, retain) NSArray *eventAlertsArr;
@end

@protocol EventAlertsDelegate <NSObject>

- (void)eventsAlertTimeString:(NSString *)alertSt atIndex:(NSInteger) index;

@end
