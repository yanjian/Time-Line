//
//  FriendGroupShowViewController.h
//  Time-Line
//
//  Created by IF on 15/1/26.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendGroup.h"
@ class FriendGroupShowViewController ;
typedef void (^FriendGroupShowBlock)(FriendGroupShowViewController * selfViewController,FriendGroup *friendGroup);

@interface FriendGroupShowViewController : UIViewController

@property (nonatomic,copy) FriendGroupShowBlock fBlock ;

@end
