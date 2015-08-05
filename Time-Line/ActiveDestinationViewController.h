//
//  ActiveDestinationViewController.h
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "XLButtonBarPagerTabStripViewController.h"
#import "ActiveBaseInfoMode.h"
#import "UIColor+HexString.h"

@class ManageViewController ;

@interface ActiveDestinationViewController : XLButtonBarPagerTabStripViewController
@property (nonatomic, retain)  ActiveBaseInfoMode *activeEventInfo;

@property (nonatomic, retain)  ManageViewController *manageViewController;

@end

