//
//  HeadView.h
//  Time-Line
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendGroup;
@protocol HeadViewDelegate <NSObject>

@optional
- (void)clickHeadView;

@end

@interface HeadView : UIView

@property (nonatomic, strong) FriendGroup *friendGroup;

@property (nonatomic, weak) id <HeadViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end
