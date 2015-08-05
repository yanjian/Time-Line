//
//  ActiveSetingTableViewController.h
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveEventMode.h"
@protocol ActiveSetingTableViewControllerDelegate;
@interface ActiveSetingTableViewController : UITableViewController

@property (strong, nonatomic) ActiveEventMode * activeEvent ;

@property (nonatomic,assign) id<ActiveSetingTableViewControllerDelegate> delegate;

@end


@protocol ActiveSetingTableViewControllerDelegate <NSObject>

@optional

/***
 *
 *用户是否在该页面设置了东西：isChange --> YES 表示用户在页面有改动：---刷新父页面---
 */
-(void)activeSetingTableViewControllerDelegate:(ActiveSetingTableViewController *) activeViewController isChange:(BOOL) isChange;

@end