//
//  ActiveAlbumsTableViewController.h
//  Time-Line
//
//  Created by IF on 15/4/8.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
@interface ActiveAlbumsTableViewController : UITableViewController<XLPagerTabStripChildItem>

@property (nonatomic,copy) NSString * eid ;

@end
