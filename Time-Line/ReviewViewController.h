//
//  ReviewViewController.h
//  Go2
//
//  Created by IF on 15/3/31.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ActiveDataMode.h"
#import "ActiveEventModel.h"

@interface ReviewViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic , retain) ActiveDataMode *activeDataMode;
@property (weak, nonatomic) IBOutlet UITableView *reviewTableview;

@property (assign ,nonatomic ) BOOL isEdit ;
@property (strong, nonatomic) ActiveEventModel *activeEvent ;
@end
