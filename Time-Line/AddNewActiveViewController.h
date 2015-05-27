//
//  AddNewActiveViewController.h
//  Go2
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ActiveEventMode.h"

@interface AddNewActiveViewController : UIViewController{
    UITableView * _addNewActiveTableView ;
}
@property (nonatomic,strong) IBOutlet UITableView * addNewActiveTableView ;


@property (assign, nonatomic) BOOL isEdit ;// 为Yes 表示是编辑 ，为no 表示是新增
@property (strong, nonatomic) ActiveEventMode *activeEvent ;

@end
