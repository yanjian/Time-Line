//
//  ManageViewController.h
//  Go2
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageViewController : UIViewController
@property (nonatomic,retain) NSMutableArray *_activeArr;  //用于显示活动的数组

//刷新所有数据（有动画）
- (void)setupRefresh ;
//刷新表格
-(void)fefreshTableView;
@end
