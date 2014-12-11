//
//  ManageViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ManageViewController.h"

@interface ManageViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 44, kScreen_Width, kScreen_Height-naviHigth) style:UITableViewStyleGrouped];
//    self.tableView.dataSource=self;
//    self.tableView.delegate=self;
    self.view =self.tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
