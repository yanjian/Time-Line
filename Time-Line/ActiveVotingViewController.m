//
//  ActiveVotingViewController.m
//  Time-Line
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveVotingViewController.h"
#import "DateTimeVoteTableViewCell.h"

static NSString * cellVotingId = @"cellVotingId";
@interface ActiveVotingViewController ()<ASIHTTPRequestDelegate>{
    NSMutableArray * activeTimeVoteArr ;
    
    NSMutableDictionary *_selectIndexPathDic; //用户选择的indexPath
    
    VoteTimeType voteTimeType;
}

@end

@implementation ActiveVotingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectIndexPathDic = @{}.mutableCopy ;
    //解析数据
    activeTimeVoteArr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *tmpDic in self.timeArr) {
        ActiveTimeVoteMode * activeTimeVote = [[ActiveTimeVoteMode  alloc] init];
        [activeTimeVote parseDictionary:tmpDic];
        [activeTimeVoteArr addObject:activeTimeVote];
    }
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
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
        cell.accessoryView = imageView ;
        imageView.center = cell.accessoryView.center ;
    }
    ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:indexPath.section];
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    NSDate * start = [dateFormatter dateFromString:activeTimeVote.startTime];
    NSDate * end = [dateFormatter dateFromString:activeTimeVote.endTime];
    
    cell.startTimeLab.text = [NSString stringWithFormat:@"From - %@",[self formaterDate:start]] ;
    cell.endTimeLab.text   = [NSString stringWithFormat:@"To - %@",[self formaterDate:end]] ;
    cell.suggestLab.text   = @"suggested by  " ;
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    ActiveTimeVoteMode * activeTimeVote = [activeTimeVoteArr objectAtIndex:indexPath.section];

    NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
    DateTimeVoteTableViewCell *stv = (DateTimeVoteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (![_selectIndexPathDic objectForKey:indexPathStr]) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_tick"] ;
        stv.accessoryView = imageView;
        [_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
        voteTimeType = voteTimeType_Vote ;
    }else {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
        stv.accessoryView = imageView;
        [_selectIndexPathDic removeObjectForKey:indexPathStr];
        voteTimeType = voteTimeType_cancel ;
    }
    ASIHTTPRequest *voteTimeRequest = [t_Network httpPostValue:@{ @"eid":activeTimeVote.eid, @"tid":activeTimeVote.Id, @"type":@(voteTimeType_Vote) }.mutableCopy Url:anyTime_VoteTimeForEvent Delegate:self Tag:anyTime_VoteTimeForEvent_tag];
    
    [voteTimeRequest startAsynchronous];
    
}


#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responeStr = [request responseString];
    NSLog(@"%@", [request responseString]);
    id groupObj = [responeStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_VoteTimeForEvent_tag: {
            NSString *statusCode = [groupObj objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
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
