//
//  Go2ChildTableViewController.h
//  Go2
//
//  Created by IF on 15/9/16.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//
#import "XHMessageTableViewController.h"
#import "XLPagerTabStripViewController.h"
#import "ActiveEventModel.h"

@interface Go2ChildTableViewController : XHMessageTableViewController<XLPagerTabStripChildItem>
@property (strong, nonatomic) ActiveEventModel * activeEvent;
@end
