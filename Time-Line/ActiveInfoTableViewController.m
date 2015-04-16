//
//  ActiveInfoTableViewController.m
//  Time-Line
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveInfoTableViewController.h"
#import "NavigationController.h"
#import "ActiveImageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "InviteesViewController.h"
#import "UserInfo.h"

static NSString * cellId = @"activeInfoID";
static NSString * cellStyleV1 = @"static NSString";

@interface ActiveInfoTableViewController ()<ASIHTTPRequestDelegate>{
    ActiveImageTableViewCell * activeImgCell ;
    UILabel * inviteCountLab;
    NSMutableArray *joinArr ;//存放参加的用户的id ；
    NSMutableArray * selectFriendArr ;//存放所有的人员：id
    
    int joinCount;//参加的人数；
    NSString * userId;
    
    UIView *_joinAndNoJoinView;
    NSArray *_joinAndNoJoinArr;
    NSString *_joinStatus;
}
@end

@implementation ActiveInfoTableViewController
@synthesize activeEvent ;

- (void)viewDidLoad {
    [super viewDidLoad];
    joinArr = @[].mutableCopy ;
    selectFriendArr = @[].mutableCopy ;
    userId = [UserInfo currUserInfo].Id;
    
    [self createJoinActiveBtn];
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"INFO" ;
}


#pragma mark -创建参加或不参加按钮
- (void)createJoinActiveBtn {
    UserInfo * userInfo = [UserInfo currUserInfo];
    for (NSDictionary *dic in self.activeEvent.member) {
        NSString *uid = [dic objectForKey:@"uid"];
        
        if ([userInfo.Id isEqualToString:[NSString stringWithFormat:@"%@", uid]]) {
            int join = [[dic objectForKey:@"join"] integerValue];
            if (join == 1) {
                _joinStatus = @"1";//参加
            }
            else {
                _joinStatus = @"2";//bu参加
            }
        }
    }

    
    _joinAndNoJoinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    
    UIButton *joinBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    [joinBtn setTitle:@"Joining" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [joinBtn setTag:3];
    [joinBtn setTitleColor:purple forState:UIControlStateSelected];
    
    [joinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *noJoinBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 44)];
    [noJoinBtn setTitle:@"Not Joining" forState:UIControlStateNormal];
    [noJoinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [noJoinBtn setTitleColor:purple forState:UIControlStateSelected];
    [noJoinBtn setTag:4];
    [noJoinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    if ([_joinStatus isEqualToString:@"1"]) {//表示参加
        [joinBtn setTitleColor:purple forState:UIControlStateNormal];
    }
    else {
        [noJoinBtn setTitleColor:purple forState:UIControlStateNormal];
    }
    _joinAndNoJoinArr = [NSArray arrayWithObjects:joinBtn, noJoinBtn, nil];
    
    [_joinAndNoJoinView addSubview:joinBtn];
    [_joinAndNoJoinView addSubview:noJoinBtn];
}


#pragma mark -参加或不参加按钮事件
- (void)eventTouchUpInsideJoin:(UIButton *)sender {
    for (UIButton *btn in _joinAndNoJoinArr) {
        btn.selected = NO;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    sender.selected = YES;
    int joinType = 0;
    if (sender.tag == 3) {
        _joinStatus = @"1";//表示参加
        joinType = 1;
    }
    else if (sender.tag == 4) {
        _joinStatus = @"2";//表示不参加
        joinType = 2;//不参加
    }
    ASIHTTPRequest *joinRequest = [t_Network httpGet:@{ @"eid":self.activeEvent.Id, @"join":@(joinType) }.mutableCopy Url:anyTime_JoinEvent Delegate:self Tag:anyTime_JoinEvent_tag];
    [joinRequest startAsynchronous];
}



- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSDictionary *tmpDic = [responseStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_JoinEvent_tag:
        {
            NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                [MBProgressHUD showSuccess:@"Success！"];
            }
        }
        break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 160.f;
    }
    if (indexPath.section == 8 && indexPath.row == 0) {
        if (activeEvent.coordinate && ![activeEvent.coordinate isEqualToString:@""]) {
            return 160.f;
        }else{
            return 0.0f;
        }
    }
     return 44.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        inviteCountLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        [joinArr removeAllObjects];
        [selectFriendArr removeAllObjects];
        for (NSDictionary *tmpDic in activeEvent.member) {
            int join = [[tmpDic objectForKey:@"join"] integerValue];//参加的人：1表示已经参加，2表示不参加
            if (join == 1) {//参加的人数
                joinCount++;
                [joinArr addObject:[tmpDic objectForKey:@"uid"]];
            }
            [selectFriendArr addObject:[tmpDic objectForKey:@"uid"]];
        }
        inviteCountLab.text = [NSString stringWithFormat:@"%i Invites - %i Going" , activeEvent.member.count,joinCount] ;
        inviteCountLab.textAlignment = NSTextAlignmentCenter ;
        inviteCountLab.backgroundColor = [UIColor whiteColor];
        inviteCountLab.textColor = [UIColor grayColor];
        return inviteCountLab ;
    }
   
    return nil ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 20.f ;
    }
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (!activeImgCell) {
            activeImgCell =(ActiveImageTableViewCell *)[[[UINib nibWithNibName:@"ActiveImageTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
        NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_urlStr];
        [activeImgCell.activeImag sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018.jpg"] completed:nil];
        return activeImgCell ;
    }else{
         if (indexPath.section == 1||indexPath.section == 2 || indexPath.section == 5 || indexPath.section == 6 ||indexPath.section == 8){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId] ;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                cell.textLabel.textAlignment = NSTextAlignmentCenter ;
            }
            if(indexPath.section == 1 && indexPath.row == 0){
                 cell.textLabel.text = activeEvent.title ;
                
            }else if(indexPath.section == 2 && indexPath.row == 0){
                
                for (UIView * view in cell.subviews) {
                    [view removeFromSuperview];
                }
                
                UIScrollView * fivScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 38*activeEvent.member.count, 30)];
                fivScrollV.contentSize = CGSizeMake(38*activeEvent.member.count, 0);
                for (int i = 0; i < activeEvent.member.count ; i++) {
                    UIImageView *fiv =  [[UIImageView alloc] initWithFrame:CGRectMake((38*i)+(i==0?4:0), 0, 30, 30)];
                    fiv.layer.masksToBounds = YES ;
                    fiv.layer.cornerRadius = fiv.bounds.size.width/2;
                    NSDictionary * tmpDic = activeEvent.member[i];
                    NSString *imgSmall = [[tmpDic objectForKey:@"imgSmall"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:_urlStr];
                        [fiv sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    [fivScrollV addSubview:fiv];
                }
                [cell addSubview:fivScrollV];
                
                UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                [addBtn setImage:[UIImage imageNamed:@"add_default"] forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(addFriendsList:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:addBtn];
                cell.accessoryView = addBtn ;
                fivScrollV.center = cell.center ;
                
            }else if ( indexPath.section == 5  && indexPath.row == 0 ){
                [cell.contentView addSubview:_joinAndNoJoinView];
            }else if ( indexPath.section == 6  && indexPath.row == 0 ){
                cell.textLabel.text = activeEvent.note ;
            }else if ( indexPath.section == 8  && indexPath.row == 0 ){
                if (activeEvent.coordinate && ![@"" isEqualToString:activeEvent.coordinate]) {
                    NSArray *tmpArr = [activeEvent.coordinate componentsSeparatedByString:@";"];
                    MKMapView *vMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0,kScreen_Width, 160)];
                    vMap.delegate = self;
                    vMap.centerCoordinate = CLLocationCoordinate2DMake([tmpArr[0] doubleValue], [tmpArr[1] doubleValue]);
                    vMap.camera.altitude = 20;
                    vMap.showsBuildings = YES;
                    vMap.zoomEnabled = NO ;
                    vMap.scrollEnabled = NO ;
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = vMap.centerCoordinate;
                    annotation.title = activeEvent.location;
                    [vMap addAnnotation:annotation];
                    [cell addSubview:vMap];
                }
            }
           return cell;
         }else if (indexPath.section == 3||indexPath.section == 4 || indexPath.section == 7){
             UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStyleV1] ;
             if (!cell) {
                 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellStyleV1];
                 cell.selectionStyle = UITableViewCellSelectionStyleNone ;
             }

             if ( indexPath.section == 3  && indexPath.row == 0 ){
                 UIImage *icon = [UIImage imageNamed:@"Alert_Hour"];
                 CGSize itemSize = CGSizeMake(20, 20);
                 UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
                 CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                 [icon drawInRect:imageRect];
                 cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
                 cell.textLabel.text = @"Time:" ;
                 if ([userId isEqualToString:self.activeEvent.create]) {
                     cell.detailTextLabel.text = @"Confirm" ;
                 }else{
                     cell.detailTextLabel.text = @"Voting" ;
                 }
             }else if ( indexPath.section == 4  && indexPath.row == 0 ){
                 cell.textLabel.text = @"Due date to vote:" ;
                 NSDate * voteEndTime = [self StringToDate:@"yyyy-MM-DD HH:mm" formaterDate:activeEvent.voteEndTime];
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"EEE d MMM"];
                 NSString *dateAndTime =  [dateFormatter stringFromDate:voteEndTime];
                 cell.detailTextLabel.text =  dateAndTime;
             }else if ( indexPath.section == 7  && indexPath.row == 0 ){
                 cell.textLabel.text = @"Location:" ;
                 if(activeEvent.location && ![@"" isEqualToString:activeEvent.location]){
                    cell.detailTextLabel.text = activeEvent.location ;
                 }else{
                     cell.detailTextLabel.text = @"No location" ;
                 }
             }
             return cell;
         }
    }
    return nil;
}


-(void)addFriendsList:(UIButton *)sender {
    InviteesViewController * inviteesVc = [[InviteesViewController alloc] init];
    inviteesVc.navStyleType = NavStyleType_LeftModelOpen ;
    inviteesVc.eid = self.activeEvent.Id ;
    inviteesVc.joinArr = joinArr ;
    inviteesVc.joinAllArr = selectFriendArr ;
    NavigationController *navC= [[NavigationController alloc] initWithRootViewController:inviteesVc];
    navC.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navC.navigationBar setBarTintColor:HEXCOLOR(0x19C5FF00)];
    [self.navigationController presentViewController:navC animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([userId isEqualToString:self.activeEvent.create]) {//是自己创建的就不跳转咯......
        if ( indexPath.section == 3 && indexPath.row == 0 ) {
            if (self.activeDestinationBlank ) {
                self.activeDestinationBlank();
            }
        }
    }
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma marke - 格式化时间Date
- (NSDate *)StringToDate:(NSString *)format formaterDate:(NSString *) dateStr {
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSDate *loctime = [formatter dateFromString:dateStr];
    NSLog(@"%@", loctime);
    return loctime;
}

@end
