//
//  NewPurposeEventTimeViewController.h
//  Go2
//
//  Created by IF on 15/6/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//
#import <EventKitUI/EventKitUI.h>
#import "MGCDayPlannerEKViewController.h"

#import "ActiveDataMode.h"
#import "ActiveEventMode.h"
@interface NewPurposeEventTimeViewController : UIViewController

@property (nonatomic , retain) ActiveDataMode *activeDataMode;
@property (nonatomic , assign) BOOL isEdit ;
@property (strong, nonatomic) ActiveEventMode *activeEvent ;


@end
