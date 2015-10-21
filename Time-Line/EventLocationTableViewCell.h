//
//  EventLocationTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
@interface EventLocationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *locationbgView;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationName;

@property (weak, nonatomic) IBOutlet UIView *locationShowMapView;

@end
