//
//  AllDateViewController.h
//  Time-Line
//
//  Created by IF on 15/3/27.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define startTime @"start"
#define endTime   @"end"

@protocol AllDateViewControllerDelegate;

@interface AllDateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id<AllDateViewControllerDelegate>  delegate;

@end




@protocol AllDateViewControllerDelegate <NSObject>

@optional
-(void)allDateViewController:(AllDateViewController *) allDateViewController dateDic:(NSDictionary *) dateDic ;

@end