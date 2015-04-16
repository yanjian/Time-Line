//
//  EventConfirmTimeTableViewController.h
//  Time-Line
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventConfirmTimeTableViewController.h"
#import "ActiveTimeVoteMode.h"
@protocol EventConfirmTimeTableViewControllerDelegate;

@interface EventConfirmTimeTableViewController : UITableViewController

@property (nonatomic , retain) NSMutableArray * timeArr ;
@property (nonatomic , retain) NSMutableArray * etArr;
@property (nonatomic , copy)   NSString * eid;
@property (nonatomic , retain) id<EventConfirmTimeTableViewControllerDelegate> delegate ;
@end


@protocol EventConfirmTimeTableViewControllerDelegate <NSObject>

-(void)eventConfirmTimeTableViewControllerDelegate:(EventConfirmTimeTableViewController *) eventConfirmVC setTimeId:(NSString *)tid ;
@end