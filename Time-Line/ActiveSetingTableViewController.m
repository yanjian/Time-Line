//
//  ActiveSetingTableViewController.m
//  Time-Line
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveSetingTableViewController.h"
#import "ActiveSetingShowTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"
#import "AddNewActiveViewController.h"
#import "InviteesTimeTableViewCell.h"
#import "EventConfirmTimeTableViewController.h"
#import "InviteesJoinOrReplyTableViewController.h"
#import "ActiveTimeVoteMode.h"
#import "ActiveVoteTimeModel.h"
#import "MemberDataModel.h"

static NSString * cellActiveSeting = @"cellActiveSeting" ;

@interface ActiveSetingTableViewController ()<EventConfirmTimeTableViewControllerDelegate>{
    NSMutableArray * memberArr ;
    NSString * userId;
    NSMutableArray * timeArr;
    ActiveTimeVoteMode *activeTime ;//用户选择的时间
}

@end

@implementation ActiveSetingTableViewController
@synthesize activeEvent;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event Settings" ;
    
    userId = [UserInfo currUserInfo].Id;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 35, 18)];
    [rightBtn setTag:2];
    [rightBtn setTitle:@"Edit" forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    memberArr = @[].mutableCopy ;
    for (NSDictionary *memDic in self.activeEvent.member) {
        MemberDataModel * member = [[MemberDataModel alloc] init];
        [member parseDictionary:memDic];
        [memberArr addObject:member];
    }
    
    timeArr = @[].mutableCopy ;
    for (NSDictionary *timeDic in self.activeEvent.time) {
        ActiveTimeVoteMode * activeTimeVoet = [[ActiveTimeVoteMode alloc] init] ;
        [activeTimeVoet parseDictionary:timeDic];
        [timeArr addObject:activeTimeVoet];
        if ([activeTimeVoet.finalTime intValue] == 2 ) {
            activeTime = activeTimeVoet ;
        }
    }
    
    [self createDeleteEventBtn];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)createDeleteEventBtn{
    UIControl * deleteBtn = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 88)];
    UIButton * deletebtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    
    [deletebtn setTitle:@"Delete Event" forState:UIControlStateNormal];
    [deletebtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [deletebtn setBackgroundColor:[UIColor clearColor]];
    [deleteBtn addSubview:deletebtn];
    deletebtn.center = deleteBtn.center ;
    [deletebtn addTarget:self action:@selector(deleteEventData:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = deleteBtn ;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 ) {
            return 100.f;
        }else{
          return activeTime == nil ? 44.f : 64.f;
        }
    }else if (indexPath.section == 1 ){
        return 84.f;
    }else if (indexPath.section == 2 ){
        return 64.f;
    }
    return 44.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.001f;
    }
    return 20.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        ActiveSetingShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"activeSetingShowID"] ;
        if (!cell) {
            cell =(ActiveSetingShowTableViewCell *)[[[UINib nibWithNibName:@"ActiveSetingShowTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        }
        NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_urlStr];
        [cell.activeImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018.jpg"] completed:nil];
        cell.activeTitle.text = self.activeEvent.title ;
        for (MemberDataModel * member in memberArr) {
            NSNumber * uidStr = member.uid;
            if ([uidStr intValue] == [self.activeEvent.create intValue]) {
                cell.activeDesc.text = [NSString stringWithFormat:@"Host: %@",member.username];
                break ;
            }
        }
        return cell ;
    }else if(indexPath.section == 0 && indexPath.row == 1){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cenvetTimeId"] ;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cenvetTimeId"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                cell.textLabel.textAlignment = NSTextAlignmentCenter ;
             }
            if (activeTime) {
                for (UIView * subView in cell.contentView.subviews) {
                    [subView removeFromSuperview];
                }
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
                NSDate  * startDate = [dateFormatter dateFromString:activeTime.startTime] ;
                NSDate  * endDate   = [dateFormatter dateFromString:activeTime.endTime] ;
                
                UIImageView * alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Alert_Hour"]];
                alertView.frame = CGRectMake(20, 22, 20, 20);
                UILabel * startLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, kScreen_Width-75, 20)];
                [startLab setText:[self formaterDate:startDate]];
                UILabel * endLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, kScreen_Width-75, 20)];
                [endLab   setText:[self formaterDate:endDate]];
                [cell.contentView addSubview:alertView];
                [cell.contentView addSubview:startLab];
                [cell.contentView addSubview:endLab];
            }else{
                cell.textLabel.textColor = [UIColor colorWithHexString:@"4fabe8"];
                cell.textLabel.text = @"Confirm Event Time" ;
            }
            return cell ;
    }else if ( indexPath.section == 1 && indexPath.row == 0 ){
        InviteesTimeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"activeInviteesShowID"] ;
        if (!cell) {
            cell =(InviteesTimeTableViewCell *)[[[UINib nibWithNibName:@"InviteesTimeTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        }
        int join = 0 ;
        int noJoin = 0 ;
        int noReply = 0 ;
        
        for (MemberDataModel * member in memberArr) {
            if ([member.join intValue] == 1) {
                join++;
            }else if ([member.join intValue] == 2){
                noJoin ++ ;
            }else{
                noReply++;
            }
        }
        cell.joinCount.text = [NSString stringWithFormat:@"%i Joining", join];
        cell.noJoinCount.text = [NSString stringWithFormat:@"%i Not Joining", noJoin];
        cell.noReplyCount.text = [NSString stringWithFormat:@"%i No Reply", noReply];
        return cell ;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellActiveSeting] ;
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellActiveSeting];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        }
        if (indexPath.section == 2 && indexPath.row == 0){
            for (UIView *childView in cell.contentView.subviews) {
                [childView removeFromSuperview];
            }

            UISwitch *purporseSwitch = [[UISwitch alloc] init];
            purporseSwitch.tag = 1 ;
            
            for (MemberDataModel * member in memberArr) {
                if ([member.uid integerValue] == [userId integerValue]) {
                    if ([member.notification intValue] == 1) {
                        purporseSwitch.on = YES ;
                    }else{
                         purporseSwitch.on = NO ;
                    }
                    break ;
                }
            }
            
            [purporseSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = purporseSwitch;
           
            UILabel * purporseLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-100, 64)];
            purporseLab.text = @"   Receive notification \n   for new updates";
            [purporseLab setNumberOfLines:2];
            [cell.contentView addSubview:purporseLab];
        }        
        return cell ;
    }
    return nil;
}

-(void)switchValueChange:(UISwitch *) sender{
    
    ASIHTTPRequest *activeNoti = [t_Network httpPostValue:@{ @"eid":self.activeEvent.Id,@"type":sender.on ? @1 : @2 }.mutableCopy Url:anyTime_EventNotification Delegate:nil Tag:anyTime_EventNotification_tag];
    __block ASIHTTPRequest *request = activeNoti;
    [activeNoti setCompletionBlock: ^{
        NSError *error = [request error];
        if (error) {
            return;
        }
        NSString *responseStr = [request responseString];
        id objData =  [responseStr objectFromJSONString];
        if ([objData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDataDic = (NSDictionary *)objData;
            NSString *statusCode = [objDataDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                
            }
        }
    }];
    
    [activeNoti setFailedBlock: ^{
        [MBProgressHUD showError:@"Setings failed, please check your network"];
    }];
    
    [activeNoti startSynchronous];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0 && indexPath.row == 1) {
        if ([userId isEqualToString:self.activeEvent.create]) {
            NSMutableArray * etArr = @[].mutableCopy ;
            for (NSDictionary *etDic in self.activeEvent.etList) {
                ActiveVoteTimeModel *activeVote = [[ActiveVoteTimeModel alloc] init];
                [activeVote parseDictionary:etDic];
                [etArr addObject:activeVote];
            }
            
            EventConfirmTimeTableViewController *eventConfirmVc = [[EventConfirmTimeTableViewController alloc] init];
            eventConfirmVc.timeArr = timeArr ;
            eventConfirmVc.etArr = etArr ;
            eventConfirmVc.eid = self.activeEvent.Id ;
            eventConfirmVc.delegate = self ;
            [self.navigationController pushViewController:eventConfirmVc animated:YES];
        }else{
            [MBProgressHUD showError:@"Sorry,only the host can\n confirm the event time."];
        }
    }else if (indexPath.section == 1 && indexPath.row == 0 ) {
        InviteesJoinOrReplyTableViewController * inviteesJoinOrReplyVC = [[InviteesJoinOrReplyTableViewController alloc] init];
        inviteesJoinOrReplyVC.memberArr = memberArr ;
        [self.navigationController pushViewController:inviteesJoinOrReplyVC animated:YES];
    }
}

-(void)eventConfirmTimeTableViewControllerDelegate:(EventConfirmTimeTableViewController *) eventConfirmVC setTimeId:(NSString *)tid {
    for (ActiveTimeVoteMode *tmpATime in timeArr) {
        if ([tmpATime.Id intValue] == [tid intValue]) {
            activeTime = tmpATime ;
            break ;
        }
    }
    [eventConfirmVC.navigationController popViewControllerAnimated:YES ];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)backToEventView:(UIButton *)sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES] ;
        }break;
        case 2:{
            AddNewActiveViewController * addNewActiveVc = [[AddNewActiveViewController alloc] init];
            addNewActiveVc.isEdit = YES ;
            addNewActiveVc.activeEvent = self.activeEvent ;
            [self.navigationController pushViewController:addNewActiveVc animated:YES];
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

-(void)deleteEventData:(UIButton *)sender {
    
    ASIHTTPRequest *activeNoti = [t_Network httpPostValue:@{ @"eid":self.activeEvent.Id }.mutableCopy Url:anyTime_QuitEvent Delegate:nil Tag:anyTime_QuitEvent_tag];
    __block ASIHTTPRequest *request = activeNoti;
    [activeNoti setCompletionBlock: ^{
        NSError *error = [request error];
        if (error) {
            return;
        }
        NSString *responseStr = [request responseString];
        id objData =  [responseStr objectFromJSONString];
        if ([objData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDataDic = (NSDictionary *)objData;
            NSString *statusCode = [objDataDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
    
    [activeNoti setFailedBlock: ^{
        [MBProgressHUD showError:@"Delete failed, please check your network"];
    }];
    [activeNoti startSynchronous];
}
@end
