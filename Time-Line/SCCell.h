//
//  MyCell.h
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kWidthMargin 1
#define kHeightMargin 3
#import <UIKit/UIKit.h>

@class SCCell,SCHeadView,MeetModel;

@protocol MyCellDelegate <NSObject>

-(void)myHeadView:(SCHeadView *)headView point:(CGPoint)point;

@end

@interface SCCell : UITableViewCell
@property (nonatomic,assign) id<MyCellDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *currentTime;
@property (nonatomic,assign) int index;
@end
