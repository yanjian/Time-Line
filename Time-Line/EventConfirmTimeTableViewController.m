//
//  EventConfirmTimeTableViewController.m
//  Go2
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "EventConfirmTimeTableViewController.h"
#import "DateVoteShowTableViewCell.h"

@interface EventConfirmTimeTableViewController ()

@end

@implementation EventConfirmTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm Event Time" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventSettingView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.timeArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DateVoteShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"voteTimeCellID"];
    if (!cell) {
        cell = (DateVoteShowTableViewCell *)[[[UINib nibWithNibName:@"DateVoteShowTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    }
    ActiveTimeVoteMode * activeTime = self.timeArr[indexPath.section];
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    
    NSDate  * startDate = [dateFormatter dateFromString:activeTime.start] ;
    NSDate  * endDate   = [dateFormatter dateFromString:activeTime.end] ;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    cell.startTimeOrDay.text = [NSString stringWithFormat:@"From - %@",[self formaterDate:startDate] ]  ;
    cell.timeOrEenTime.text  = [NSString stringWithFormat:@"  To - %@",[self formaterDate:endDate]];
    
    UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    if([activeTime.status integerValue] == 1){
        selectBtn.selected = YES;
    }
    [selectBtn setTitle:@"SELECT" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [selectBtn setTitleColor:purple forState:UIControlStateSelected];
    selectBtn.tag =  indexPath.section ;
    [selectBtn addTarget:self action:@selector(comfirmActiveTime:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = selectBtn ;
    cell.showTimeInterval.text = @"0";
    return cell;
}

-(void)comfirmActiveTime:(UIButton *)sender{
    sender.selected = NO ;
     ActiveTimeVoteMode * activeTime = self.timeArr[sender.tag];
    ASIHTTPRequest *request = [t_Network httpGet:@{@"method":@"confirmTime",@"eid":self.eid, @"timeId":activeTime.Id }.mutableCopy Url:Go2_socials Delegate:nil Tag:Go2_ConfirmEventTime_tag];
    __block ASIHTTPRequest *aliasRequest = request;
    [request setCompletionBlock: ^{
        NSString *responseStr = [aliasRequest responseString];
        id objGroup = [responseStr objectFromJSONString];
        if ([objGroup isKindOfClass:[NSDictionary class]]) {
            int statusCode = [[objGroup objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
                sender.selected = YES ;
                if (self.delegate && [self.delegate respondsToSelector:@selector(eventConfirmTimeTableViewControllerDelegate:setTimeId:)]) {
                    [self.delegate eventConfirmTimeTableViewControllerDelegate:self setTimeId:activeTime.Id];
                }
            }
        }
    }];
    [request setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error!"];
    }];
    [request startAsynchronous];
}

-(void)backToEventSettingView:(UIButton *) sender {
    switch (sender.tag) {
        case 1:{
            if ( self.delegate && [self.delegate respondsToSelector:@selector(popEventConfirmTimeTableViewController:)] ) {
                [self.delegate popEventConfirmTimeTableViewController:self];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 2:{
            
        }break;
 
        default:
            break;
    }
}


-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d EEE,yyyy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}
@end
