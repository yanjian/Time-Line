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

@interface NoticesViewController ()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate>{
    NSMutableArray * _noticeArr;

}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation NoticesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, naviHigth, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-frame.origin.y) style:UITableViewStyleGrouped];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    // [self loadUserRequestInfo];
    
}

-(void)loadUserRequestInfo{
    ASIHTTPRequest  *msgRequest = [t_Network httpGet:nil Url:anyTime_GetUserMessage2 Delegate:self Tag:anyTime_GetUserMessage2_tag];
    [msgRequest startAsynchronous];
    
}



- (void)requestFinished:(ASIHTTPRequest *)request{
    switch (request.tag) {
        case anyTime_GetUserMessage2_tag:{
            
        
        
        }
        break;
            
        default:
            break;
    }

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
        return 215.f;
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
