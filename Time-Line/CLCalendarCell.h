//
//  CLCalendarCell.h
//  Time-Line
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLDay.h"


@class CLCalendarCell;
@protocol CLCalendarCellDelegate <NSObject>

- (void)selectDate:(CLCalendarCell*)cell weekDay:(NSInteger)index;

- (int)getShowMonth;

- (int)getShowSelectDay:(CLCalendarCell*)cell;
@end


@interface CLCalendarCell : UITableViewCell {
        NSMutableArray *_btnArray;
        NSMutableArray *_bgArray;
    NSMutableArray *_pointArray;
}


@property (nonatomic, weak) id<CLCalendarCellDelegate> detelegate;
@property (nonatomic, strong) NSArray *weekArr;
@property (nonatomic,retain)NSString* time;
@property (nonatomic,retain)UIImageView* imageview;
@end
