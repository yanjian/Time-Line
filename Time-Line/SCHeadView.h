//
//  HeadView.h
//  表格
//
//  Created by zzy on 14-5-5.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHeadView;

@protocol HeadViewDelegate <NSObject>

-(void)headView:(SCHeadView *)headView point:(CGPoint)point;

@end

@interface SCHeadView : UIView
@property (nonatomic,strong) NSString *num;
@property (nonatomic,strong) NSString *detail;
@property (nonatomic,assign) id <HeadViewDelegate> delegate;
@end
