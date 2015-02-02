//
//  MemberListViewController.h
//  Time-Line
//
//  Created by IF on 14/12/31.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListViewController : UIViewController

@property (nonatomic, assign) BOOL isMemberObj;
@property (nonatomic, retain) NSArray *memberArr; //这里面放的数据不同，如果 isMemberObj：YES 表示是成员对象，为no是NSDictionary
@end
