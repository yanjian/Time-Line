//
//  ActiveInfoTableViewController.h
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "XLPagerTabStripViewController.h"
#import "ActiveEventModel.h"
@ class ActiveDestinationViewController ;
typedef void(^ActiveDestinationBlank)(void);


@interface ActiveInfoTableViewController : UITableViewController<XLPagerTabStripChildItem,MKMapViewDelegate>
@property (strong, nonatomic) ActiveEventModel *activeEvent ;
@property (strong, nonatomic) ActiveDestinationBlank activeDestinationBlank;



-(void)refreshActiveEventData:(NSString *)eventId ;
@end