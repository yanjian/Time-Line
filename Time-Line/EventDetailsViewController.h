//
//  EventDetailsViewController.h
//  Go2
//
//  Created by IF on 15/5/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class AT_Event ;
@interface EventDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *eventDetailTableView;

@property (nonatomic, retain) AT_Event *event;

@end
