//
//  ActiveFooterView.h
//  Time-Line
//
//  Created by IF on 15/1/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActiveFooterViewDelegate;
@interface ActiveFooterView : UIView
@property (nonatomic ,retain) id<ActiveFooterViewDelegate> delegate;
@property (nonatomic , retain) NSDictionary * voteOptionDic;
@property (nonatomic , assign) NSInteger selectSection;
@end

@protocol ActiveFooterViewDelegate <NSObject>
@optional

-(void)activeFooterView:(ActiveFooterView *) footerView returnValue:(NSArray *) returnArr selectSection:(NSInteger) section;

@end