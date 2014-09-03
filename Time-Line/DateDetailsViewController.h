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
@property(retain,nonatomic)NSDictionary* datedic;
@property (weak, nonatomic) IBOutlet UITableView *detaileTableview;

@property(retain,nonatomic)NSArray* dateArr;
@end
