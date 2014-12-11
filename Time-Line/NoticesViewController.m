//
//  NoticesViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticesViewController.h"
#import "ActiveTableViewCell.h"
#import "UserApplyTableViewCell.h"

@interface NoticesViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NoticesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 44, kScreen_Width, kScreen_Height-naviHigth) style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.view =self.tableView;
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section%2==0) {
        return 110.f;
    }else{
        return 170.f;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *activeId=@"activeCellId";
    
    if (indexPath.section%2==0) {
        UserApplyTableViewCell *userApplyCell=[tableView dequeueReusableCellWithIdentifier:activeId];
        if (!userApplyCell) {
            
            userApplyCell = (UserApplyTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"UserApplyTableViewCell" owner:self options:nil] firstObject];
        }
        return userApplyCell;
    }else{
        ActiveTableViewCell *activeCell=[tableView dequeueReusableCellWithIdentifier:activeId];

        if (!activeCell) {
            
            activeCell = (ActiveTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ActiveTableViewCell" owner:self options:nil] firstObject];
        }
         return activeCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
