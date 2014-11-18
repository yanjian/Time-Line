//
//  DateDetailsViewController.h
//  Time-Line
//
//  Created by connor on 14-4-8.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddEventViewController.h"
@interface DateDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *_ZVbutton;//滑动试图左边view上的左边按钮
    UIButton *_YVbutton;//滑动试图左边view上的右边按钮

}

@property(nonatomic,retain) AT_Event* event;
@property(retain,nonatomic) NSDictionary* datedic;//一个事件
@property (strong, nonatomic) IBOutlet UITableView *detaileTableview;

@property(retain,nonatomic)NSArray* dateArr;//所有数据
@end
