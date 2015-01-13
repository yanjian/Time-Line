//
//  ActivedetailsViewController.h
//  Time-Line
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActiveEventMode.h"

@protocol ActivedetailsViewControllerDelegate;
@interface ActivedetailsViewController : UIViewController



@property (nonatomic,retain)  ActiveEventMode * activeEvent;
@property (nonatomic,retain)  id<ActivedetailsViewControllerDelegate> delegate;
@end

@protocol ActivedetailsViewControllerDelegate <NSObject>

@optional

-(void)cancelActivedetailsViewController:(ActivedetailsViewController *)activeDetailsViewVontroller;

@end