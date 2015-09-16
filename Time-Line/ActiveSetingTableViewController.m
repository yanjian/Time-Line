//
//  ActiveSetingTableViewController.m
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveSetingTableViewController.h"
#import "ActiveSetingShowTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"
#import "AddNewActiveViewController.h"
#import "IBActionSheet.h"
#import "InviteesTimeTableViewCell.h"
#import "EventConfirmTimeTableViewController.h"
#import "InviteesJoinOrReplyTableViewController.h"
#import "ActiveTimeVoteMode.h"
#import "ActiveVoteTimeModel.h"
#import "MemberDataModel.h"

static NSString * cellActiveSeting = @"cellActiveSeting" ;

@interface ActiveSetingTableViewController ()<EventConfirmTimeTableViewControllerDelegate,IBActionSheetDelegate>{
    NSMutableArray * memberArr ;
    NSString * userId;
    NSMutableArray * timeArr;
    ActiveTimeVoteMode *activeTime ;//用户选择的时间
    IBActionSheet * ibActionSheet;
    
    BOOL isChange;
}

@property (nonatomic,strong) UIButton * leftBtn;
@property (nonatomic,strong) UIButton * rightBtn;
@property (nonatomic,strong) UISwitch * purporseSwitch;
@property (nonatomic,strong) UILabel * purporseLab ;
@end

@implementation ActiveSetingTableViewController
@synthesize activeEvent;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event Settings" ;
    userId = [UserInfo currUserInfo].Id;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    
    if ([userId isEqualToString:self.activeEvent.createId]) {
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
    memberArr = @[].mutableCopy ;
    for (NSDictionary *memDic in self.activeEvent.invitees) {
        MemberDataModel * member = [MemberDataModel modelWithDictionary:memDic];
        [memberArr addObject:member];
    }
    
    timeArr = @[].mutableCopy ;
    for (NSDictionary *timeDic in self.activeEvent.proposeTimes) {
        ActiveTimeVoteMode * activeTimeVoet = [ActiveTimeVoteMode modelWithDictionary:timeDic]  ;
        [timeArr addObject:activeTimeVoet];
        if ([activeTimeVoet.status intValue] == 1 ) {
            activeTime = activeTimeVoet ;
        }
    }
    
    [self createDeleteEventBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(activeSetingTableViewControllerDelegate:isChange:)]) {
        [self.delegate activeSetingTableViewControllerDelegate:self isChange:isChange];
    }
}

-(void)createDeleteEventBtn{
    UIControl * deleteBtn = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 88)];
    UIButton  * deletebtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, kScreen_Width-20, 44)];
    [deletebtn setTitle:@"Delete Event" forState:UIControlStateNormal];
    [deletebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deletebtn setBackgroundColor:[UIColor redColor]];
    deletebtn.layer.cornerRadius = 5.0f;
    [deleteBtn addSubview:deletebtn];
    deletebtn.center = deleteBtn.center ;
    [deletebtn addTarget:self action:@selector( deleteEventData: ) forControlEvents:UIControlEventTouchUpInside];
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
            cell.showNoImgTitle.hidden = YES ;
        }
        
        if (activeEvent.img && ![@"" isEqualToString:activeEvent.img] ) {
            cell.showNoImgTitle.hidden = YES ;
            NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, activeEvent.img] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", _urlStr);
            NSURL *url = [NSURL URLWithString:_urlStr];
            [cell.activeImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"go2_grey"]];
        }else{
             cell.showNoImgTitle.hidden = NO ;
             [cell.activeImg setBackgroundColor: [UIColor colorWithHexString:@"2e9ef1"]];
             cell.showNoImgTitle.text = [[activeEvent.title substringToIndex:1] uppercaseString];
        }

        cell.activeTitle.text = self.activeEvent.title ;
        
        for (MemberDataModel * member in memberArr) {
            if ( [ member.uid isEqualToString:self.activeEvent.createId ]   ) {
                cell.activeDesc.text = [NSString stringWithFormat:@"Host: %@",[member.user objectForKey:@"username"]];
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
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
                NSDate  * startDate = [dateFormatter dateFromString:activeTime.start] ;
                NSDate  * endDate   = [dateFormatter dateFromString:activeTime.end] ;
                
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
            if ([member.isJoining intValue] == 1) {
                join++;
            }else if ([member.isJoining intValue] == 2){
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

            for (MemberDataModel * member in memberArr) {
                if ([ userId isEqualToString:member.uid ]    ) {
                    if ([member.isReceiveNotification intValue] == 1) {
                         self.purporseSwitch.on = YES ;
                    }else{
                         self.purporseSwitch.on = NO ;
                    }
                    break ;
                }
            }
            
            cell.accessoryView = self.purporseSwitch;
            [cell.contentView addSubview:self.purporseLab];
        }        
        return cell ;
    }
    return nil;
}

-(void)switchValueChange:(UISwitch *) sender{
    
    ASIHTTPRequest *activeNoti = [t_Network httpPostValue:@{@"method":@"updateNotifyStatus", @"eid":self.activeEvent.Id,@"status":sender.on ? @1 : @2 }.mutableCopy Url:Go2_socials Delegate:nil Tag:Go2_EventNotification_tag];
    __block typeof(activeNoti) request = activeNoti;
    [activeNoti setCompletionBlock: ^{
        NSError *error = [request error];
        if (error) {
            return;
        }
        NSString *responseStr = [request responseString];
        id objData =  [responseStr objectFromJSONString];
        if ([objData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDataDic = (NSDictionary *)objData;
            int statusCode = [[objDataDic objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
                isChange = YES ;//设置成功.....
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
    if ( indexPath.section == 0 && indexPath.row == 1 ) {
        if ([userId isEqualToString:self.activeEvent.createId]) {
            NSMutableArray * etArr = @[].mutableCopy ;
            for (NSDictionary *etDic in self.activeEvent.voteRecords) {
                ActiveVoteTimeModel *activeVote = [[ActiveVoteTimeModel alloc] init];
                [activeVote parseDictionary:etDic];
                [etArr addObject:activeVote];
            }
            
            EventConfirmTimeTableViewController *eventConfirmVc = [[EventConfirmTimeTableViewController alloc] init];
            eventConfirmVc.timeArr = timeArr ;
            eventConfirmVc.etArr   = etArr ;
            eventConfirmVc.eid     = self.activeEvent.Id ;
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

-(void)eventConfirmTimeTableViewControllerDelegate:(EventConfirmTimeTableViewController *) eventConfirmVC setTimeId:(NSString *) tid {
    for (ActiveTimeVoteMode *tmpATime in timeArr) {
        if ([ tmpATime.Id isEqualToString: tid ]   ) {
            activeTime = tmpATime ;
            isChange   = YES ;
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
    ibActionSheet=[[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Event" otherButtonTitles:nil, nil];
     [ibActionSheet showInView:self.navigationController.view];
}


#pragma -ibactionsheet的代理
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {
        ASIHTTPRequest *activeNoti = [t_Network httpPostValue:@{@"method":@"delete",@"eid":self.activeEvent.Id }.mutableCopy
                                                          Url:Go2_socials
                                                     Delegate:nil
                                                          Tag:anyTime_QuitEvent_tag];
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
                int statusCode = [[objDataDic objectForKey:@"statusCode"] intValue];
                if ( statusCode  == 1 ) {
                    //删除事件的通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:DELETEEVENTNOTI object:self userInfo:@{DELETEEVENTNOTI_INFO:self.activeEvent.Id}] ;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }];
        
        [activeNoti setFailedBlock: ^{
            [MBProgressHUD showError:@"Delete failed, please check your network"];
        }];
        [activeNoti startSynchronous];
    }
    
}

-(UIButton *)leftBtn{
    if ( !_leftBtn ) {
         _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [_leftBtn setTag:1];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
        [_leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _leftBtn;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
         _rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:CGRectMake(0, 0, 23, 23)];
        [_rightBtn setTag:2];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"Go2Icon_Edit"] forState:UIControlStateNormal] ;
        [_rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _rightBtn;
}


-(UISwitch *)purporseSwitch{
    if (!_purporseSwitch) {
        _purporseSwitch = [[UISwitch alloc] init];
        _purporseSwitch.tag = 1 ;
       [_purporseSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _purporseSwitch;
}

-(UILabel *)purporseLab{
    if (!_purporseLab) {
         _purporseLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-100, 64)];
         _purporseLab.text = @"   Receive notification \n   for new updates";
        [_purporseLab setNumberOfLines:2];
    }
    return _purporseLab ;
}
@end
