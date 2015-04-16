//
//  PurposeEventTimeViewController.h
//  Time-Line
//
//  Created by IF on 15/3/26.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveDataMode.h"
#import "ActiveEventMode.h"

@interface PurposeEventTimeViewController : UIViewController



@property (weak, nonatomic) IBOutlet  UITableView    *  dateShowTableView ;
@property (nonatomic , retain) ActiveDataMode *activeDataMode;

@property (nonatomic , assign) BOOL isEdit ;
@property (strong, nonatomic) ActiveEventMode *activeEvent ;
@end
