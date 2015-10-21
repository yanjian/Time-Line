//
//  ActiveInfoTableViewController.h
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ARSegmentControllerDelegate.h"
#import "ActiveEventModel.h"

@interface ActiveInfoTableViewController : UITableViewController<ARSegmentControllerDelegate,MKMapViewDelegate>
/**活动数据*/
@property (strong, nonatomic) ActiveEventModel *activeEvent ;

/**
 *  刷新单个活动数据
 *
 *  @param eventId 活动的ID
 */
-(void)refreshActiveEventData:(NSString *)eventId ;
@end