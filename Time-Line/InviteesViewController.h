//
//  InviteesViewController.h
//  Time-Line
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveDataMode.h"
#import "ActiveEventMode.h"

typedef NS_ENUM(NSInteger, NavStyleType) {
    NavStyleType_LeftRightSame = 0,
    NavStyleType_LeftModelOpen = 1
};


@interface InviteesViewController : UIViewController

@property (nonatomic , retain) ActiveDataMode *activeDataMode;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic)  NavStyleType  navStyleType;

@property (retain, nonatomic)  NSMutableArray * joinArr ;//存放参加的用户的id ；
@property (copy  , nonatomic)  NSString       * eid ;
@property (retain, nonatomic)  NSMutableArray * joinAllArr ;

@property (nonatomic,assign)   BOOL             isEdit ;
@property (strong, nonatomic) ActiveEventMode *activeEvent ;


@end
