//
//  ActiveVotingViewController.m
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveVotingViewController.h"
#import "DateTimeVoteTableViewCell.h"
#import "TimeSlotDetailsViewController.h"
#import "TimeVoteModel.h"
#import "MemberDataModel.h"
#import "UserInfo.h"
#import "UIColor+HexString.h"
#import "VoteMemberTableViewController.h"

static NSString * cellVotingId = @"cellVotingId";
@interface ActiveVotingViewController ()<ASIHTTPRequestDelegate>{
    NSMutableDictionary *_selectIndexPathDic; //用户选择的indexPath
    
    VoteTimeType voteTimeType;
    BOOL isTimeConfirm ;//确定是否已经确定时间 true 表示确定《《《《《《《
}
@property (strong, nonatomic) NSArray * activeTimeVoteArr ;
@property (strong, nonatomic) NSArray * voteTimeArr ;//用户对那些时间投票咯
@property (strong, nonatomic) NSArray * voteMemberArr ;

@end

@implementation ActiveVotingViewController
@synthesize activeTimeVoteArr,activeEvent ;

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectIndexPathDic = @{}.mutableCopy ;
    
    NSMutableArray * timeArr = @[].mutableCopy ;
    for (NSDictionary *tmpDic in activeEvent.proposeTimes ) {
        ActiveTimeVoteMode * activeTimeVote = [ActiveTimeVoteMode  modelWithDictionary:tmpDic];
        [timeArr addObject:activeTimeVote];
    }
    self.activeTimeVoteArr = timeArr ;
    
    NSMutableArray * voteTimeArr = @[].mutableCopy ;
    for (NSDictionary *timeVoteDic in activeEvent.voteRecords) {
        TimeVoteModel * timeVoteModel = [TimeVoteModel modelWithDictionary:timeVoteDic];
        [voteTimeArr addObject:timeVoteModel];
    }
    self.voteTimeArr = voteTimeArr ;
    
    NSMutableArray * memberArr = @[].mutableCopy ;
    for (NSDictionary *memberDic in activeEvent.invitees) {
        MemberDataModel * memberDataModel = [MemberDataModel modelWithDictionary:memberDic];
        [memberArr addObject:memberDataModel];
    }
    self.voteMemberArr = memberArr ;
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"VOTING" ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return activeTimeVoteArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DateTimeVoteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellVotingId] ;
    if (!cell) {
        cell =(DateTimeVoteTableViewCell *)[[[UINib nibWithNibName:@"DateTimeVoteTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
        UIButton * btnImgAccessory = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImgAccessory.frame = CGRectMake(0, 0, 40, 40) ;
        btnImgAccessory.tag = indexPath.section ;
        [btnImgAccessory setImage:[UIImage imageNamed:@"selecte_friend_cycle"] forState:UIControlStateNormal];
        [btnImgAccessory setImage:[UIImage imageNamed:@"selecte_friend_tick"] forState:UIControlStateSelected];
        [btnImgAccessory addTarget:self action:@selector(userVoteTimeDate:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = btnImgAccessory;
        cell.voteCount.text = @"0" ;
        
    }
    
    ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:indexPath.section];
    
    if ( [activeTimeVote.finalTime integerValue] == 2 ) {//表示时间已经确定(只要有一个确定就表示为真)
        isTimeConfirm = true ;
    }
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"ptid == %@",activeTimeVote.Id];
    NSArray * voteArr =  [self.voteTimeArr filteredArrayUsingPredicate:pre];
    
    if ( voteArr.count > 0) {
        cell.voteCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)voteArr.count];
    }
    for (TimeVoteModel * timeVote in voteArr) {
        if ( [ timeVote.uid isEqualToString:[UserInfo currUserInfo].Id ]    ) {
            UIButton * btnTmp =(UIButton *) cell.accessoryView ;
            [_selectIndexPathDic setObject:@(btnTmp.tag) forKey:[NSString stringWithFormat:@"%li", (long)btnTmp.tag]];
            btnTmp.selected = YES ;
            break;
        }
    }
    
    NSPredicate * createTimePre = [NSPredicate predicateWithFormat:@"uid == %@",activeTimeVote.createId];
    NSArray * createArr =  [self.voteMemberArr filteredArrayUsingPredicate:createTimePre];
    [createArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         MemberDataModel * memberDataModel = (MemberDataModel *) obj ;
         cell.suggestLab.text = [NSString stringWithFormat:@"suggested by %@",[memberDataModel.user objectForKey:@"username"]];
    }];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    NSDate * start = [dateFormatter dateFromString:activeTimeVote.start];
    NSDate * end   = [dateFormatter dateFromString:activeTimeVote.end];
    
    cell.startTimeLab.text = [NSString stringWithFormat:@"From - %@",[self formaterDate:start]] ;
    cell.endTimeLab.text   = [NSString stringWithFormat:@"To - %@",[self formaterDate:end]] ;
  
   
    return cell;
}


-(void)userVoteTimeDate:(UIButton *)sender{
    ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:sender.tag];
    NSString * indexPathStr = [NSString stringWithFormat:@"%li", (long)sender.tag];
    if (![_selectIndexPathDic objectForKey:indexPathStr]) {
        sender.selected = YES ;
        [_selectIndexPathDic setObject:@(sender.tag) forKey:indexPathStr];
        voteTimeType = voteTimeType_Vote ;
    }else {
        sender.selected = NO ;
        [_selectIndexPathDic removeObjectForKey:indexPathStr];
        voteTimeType = voteTimeType_cancel ;
    }
    ASIHTTPRequest *voteTimeRequest = [t_Network httpPostValue:@{@"method":@"voteTime",@"eid":activeTimeVote.eid, @"timeId":activeTimeVote.Id }.mutableCopy Url:Go2_socials Delegate:self Tag:Go2_socialsVoteTime_Tag];
    
    [voteTimeRequest startAsynchronous];
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(isTimeConfirm){
        //暂时屏蔽这一块功能。。。。
//        UIStoryboard *storyboarb = [UIStoryboard storyboardWithName:@"ActiveDestination" bundle:[NSBundle mainBundle]];
//        TimeSlotDetailsViewController *  activeDesc = ( TimeSlotDetailsViewController *)  [storyboarb instantiateViewControllerWithIdentifier:@"timeSlotDetails"];
//        UINavigationController  *nav = [[UINavigationController alloc] initWithRootViewController:activeDesc];
//        nav.navigationBar.barTintColor = [UIColor colorWithHexString:@"31aaeb"];
//        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]} ;
//        
//        ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:indexPath.section];
//        
//        NSPredicate *pre = [NSPredicate predicateWithFormat:@"tid == %@",activeTimeVote.Id];
//        NSArray * voteArr =  [self.voteTimeArr filteredArrayUsingPredicate:pre];
//        NSArray * tmpArr = @[] ;
//        for (TimeVoteModel * timeVoteModel in voteArr) {
//          NSArray * tmpMemberArr =  [self.voteMemberArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@",timeVoteModel.uid]];
//            tmpArr = [tmpArr arrayByAddingObjectsFromArray:tmpMemberArr];
//        }
//        activeDesc.voteMemberArr = tmpArr ;
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
        VoteMemberTableViewController * voteMember = [[VoteMemberTableViewController alloc] init];
        UINavigationController  *nav = [[UINavigationController alloc] initWithRootViewController:voteMember];
        nav.navigationBar.barTintColor = [UIColor colorWithHexString:@"31aaeb"];
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]} ;

        ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:indexPath.section];
        NSPredicate *pre  = [NSPredicate predicateWithFormat:@"tid == %@",activeTimeVote.Id];
        NSArray * voteArr =  [self.voteTimeArr filteredArrayUsingPredicate:pre];
        NSArray * tmpArr  = @[] ;
        for (TimeVoteModel * timeVoteModel in voteArr) {
          NSArray * tmpMemberArr =  [self.voteMemberArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@",timeVoteModel.uid]];
            tmpArr = [tmpArr arrayByAddingObjectsFromArray:tmpMemberArr];
        }
        voteMember.voteMemberArr = tmpArr ;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}


#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responeStr = [request responseString];
    NSLog(@"%@", [request responseString]);
    id groupObj = [responeStr objectFromJSONString];
    switch (request.tag) {
        case Go2_socialsVoteTime_Tag: {
            int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
            if ( statusCode  == 1 ) {
                [MBProgressHUD showSuccess:@"Vote success!"];
            }
        }
        break;
            
        default:
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm EEE d,MMM,yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}


@end
