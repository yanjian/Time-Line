//
//  SimpleEventViewController.h
//  Go2
//
//  Created by IF on 15/4/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AT_Event ;
@interface SimpleEventViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *simpleEventTableView;

@property (nonatomic, assign)  BOOL isEdit ;
@property (nonatomic, retain) AT_Event *event;
@end
