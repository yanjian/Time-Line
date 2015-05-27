//
//  ActiveSetingTableViewController.h
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveEventMode.h"
@protocol ActiveSetingDelegate ;
@interface ActiveSetingTableViewController : UITableViewController
@property (strong, nonatomic) ActiveEventMode * activeEvent ;
@property (nonatomic,assign)  id<ActiveSetingDelegate>  delegate;
@end



@protocol ActiveSetingDelegate <NSObject>

@optional
-(void)activeSetingTableViewController:(ActiveSetingTableViewController *)activeSetingVC eventId:(NSString *)eventId;

@end