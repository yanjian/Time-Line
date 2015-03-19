//
//  HeadView.h
//  Time-Line
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^headGroupNewFriendBlock)(NSString * groupName) ;

@class FriendGroup;
@protocol HeadViewDelegate <NSObject>

@optional
- (void)clickHeadView;

@end

@interface HeadView : UIView

@property (nonatomic, strong) FriendGroup *friendGroup;

@property (nonatomic, weak) id <HeadViewDelegate> delegate;

@property (nonatomic, strong) headGroupNewFriendBlock headGroupNewFriendBlock;//这里定义的只用与添加组

- (id)initWithFrame:(CGRect)frame;

@end
