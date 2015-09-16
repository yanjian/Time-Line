//
//  ActiveInfoTableViewController.m
//  Go2
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
#import "utilities.h"
#import "UIColor+HexString.h"
#import "InviteesJoinOrReplyTableViewController.h"
#import "MemberDataModel.h"

static NSString * cellId = @"activeInfoID";
static NSString * cellStyleV1 = @"cellStyleV1ID";

@interface ActiveInfoTableViewController ()<ASIHTTPRequestDelegate,InviteesViewControllerDelegate>{
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

@property (nonatomic,strong)  MKMapView    * vMap ;
@property (nonatomic,strong)  UIScrollView * fivScrollV ;
@property (nonatomic,strong)  UIButton * addBtn ;
@property (nonatomic,strong)  UIButton * joinBtn ;
@property (nonatomic,strong)  UIButton * noJoinBtn;
@end

@implementation ActiveInfoTableViewController
@synthesize activeEvent ;

- (void)viewDidLoad {
    [super viewDidLoad];
    joinArr = @[].mutableCopy ;
    selectFriendArr = @[].mutableCopy ;
    userId = [UserInfo currUserInfo].Id;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    
    [self createJoinActiveBtn];
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"INFO" ;
}


#pragma mark -创建参加或不参加按钮
- (void)createJoinActiveBtn {
    UserInfo * userInfo = [UserInfo currUserInfo];
    for (NSDictionary *dic in self.activeEvent.invitees) {
        NSString *uid = [dic objectForKey:@"uid"];
        if ([userInfo.Id isEqualToString:[NSString stringWithFormat:@"%@", uid]]) {
            NSInteger join = [[dic objectForKey:@"isJoining"] integerValue];
            if (join == 1) {
                _joinStatus = @"1";//参加
            }else if(join == 2 ) {
                _joinStatus = @"2";//bu参加
            }
        }
    }
    
    _joinAndNoJoinView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreen_Width, 44)];
    if ([_joinStatus isEqualToString:@"1"]) {//表示参加
        [self.joinBtn setSelected:YES];
        [self.noJoinBtn setSelected:NO];
    }else if([_joinStatus isEqualToString:@"2"]){
        [self.noJoinBtn setSelected:YES];
        [self.joinBtn setSelected:NO];
    }else{
        [self.joinBtn setSelected:NO];
        [self.noJoinBtn setSelected:NO];
    }
    _joinAndNoJoinArr = [NSArray arrayWithObjects:self.joinBtn, self.noJoinBtn, nil];
    [_joinAndNoJoinView addSubview:self.joinBtn];
    [_joinAndNoJoinView addSubview:self.noJoinBtn];
}


#pragma mark -参加或不参加按钮事件
- (void)eventTouchUpInsideJoin:(UIButton *)sender {
    for (UIButton *btn in _joinAndNoJoinArr) {
        btn.selected = NO;
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
    ASIHTTPRequest *joinRequest = [t_Network httpGet:@{@"method":@"updateJoinStatus", @"eid":self.activeEvent.Id, @"status":@(joinType) }.mutableCopy Url:Go2_socials Delegate:self Tag:Go2_JoinEvent_tag];
    [joinRequest startAsynchronous];
}



- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSDictionary *tmpDic = [responseStr objectFromJSONString];
    switch (request.tag) {
        case Go2_JoinEvent_tag:
        {
            int statusCode = [[tmpDic objectForKey:@"statusCode"] intValue];
            if ( statusCode  == 1 ) {
                [MBProgressHUD showSuccess:@"Success！"];
                [self refreshActiveEventData:self.activeEvent.Id] ;
            }
        }
        break;
        case Go2_getOneSocials_Tag:{
            int statusCode = [[tmpDic objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
                NSDictionary * dataDic = [[tmpDic objectForKey:@"datas"] lastObject];
                activeEvent = [ActiveEventModel modelWithDictionary:dataDic];
                [self.tableView reloadData];
            }
        }break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( indexPath.section == 0  && indexPath.row == 0) {
        return 160.f;
    }else if ( indexPath.section == 7 && indexPath.row == 0 ) {
        if (activeEvent.location && ![activeEvent.location isEqualToString:@""]) {
            return 160.f;
        }else{
            return 0.0f;
        }
    }
     return 64.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        inviteCountLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        [joinArr removeAllObjects];
        [selectFriendArr removeAllObjects];
        joinCount = 0 ;
        for (NSDictionary *tmpDic in activeEvent.invitees) {
            int join = [[tmpDic objectForKey:@"isJoining"] integerValue];//参加的人：1表示已经参加，2表示不参加
            if (join == 1) {//参加的人数
                joinCount++;
                [joinArr addObject:[tmpDic objectForKey:@"uid"]];
            }
            [selectFriendArr addObject:[tmpDic objectForKey:@"uid"]];
        }
        inviteCountLab.text = [NSString stringWithFormat:@"%lu Invites  -  %i Going" , (unsigned long)activeEvent.invitees.count,joinCount] ;
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
            activeImgCell = (ActiveImageTableViewCell *)[[[UINib nibWithNibName:@"ActiveImageTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
        NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, activeEvent.img] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_urlStr];
        [activeImgCell.activeImag sd_setImageWithURL:url placeholderImage:ResizeImage([UIImage imageNamed:@"go2_grey"], CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds))  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            UIImage *reSizeImg = nil;
            if (!image) {
                reSizeImg =  ResizeImage([UIImage imageNamed:@"go2_grey"], CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds));
            }else{
            reSizeImg = ResizeImage(image,CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds));
            }
            activeImgCell.activeImag.image = reSizeImg ;
        }];
        return activeImgCell ;
    }else{
         if (indexPath.section == 1||indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 7){
            UITableViewCell * cell
//             = [tableView dequeueReusableCellWithIdentifier:cellId] ;
//            if (!cell) {
             = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
             cell.textLabel.textAlignment = NSTextAlignmentCenter ;
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
            if(indexPath.section == 1 && indexPath.row == 0){
                cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Medium" size:20];
                cell.textLabel.text = activeEvent.title ;
                
                [self addCellSeparator:64 cell:cell];
            }else if(indexPath.section == 2 && indexPath.row == 0){
                for (UIView * view in cell.subviews) {
                    [view removeFromSuperview];
                }
                
                self.fivScrollV.contentSize = CGSizeMake(44*activeEvent.invitees.count, 0);
                UIView * memberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44*activeEvent.invitees.count, 44)];
                
                for (int i = 0; i < activeEvent.invitees.count ; i++) {
                    UIImageView *fiv =  [[UIImageView alloc] initWithFrame:CGRectMake(40*i, 0, 40, 40)];
                    fiv.layer.masksToBounds = YES ;
                    fiv.layer.cornerRadius = fiv.bounds.size.width/2;
                    NSDictionary * tmpDic = [activeEvent.invitees[i] objectForKey:@"user"];
                    NSString *imgSmall = [tmpDic objectForKey:@"thumbnail"];
                    NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:_urlStr];
                        [fiv sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    [memberView addSubview:fiv];
                }
                [self.fivScrollV addSubview:memberView];
                memberView.center = self.fivScrollV.center ;
                [cell addSubview:self.fivScrollV];
                cell.accessoryView = self.addBtn ;
               
            }else if ( indexPath.section == 4  && indexPath.row == 0 ){
                [cell.contentView addSubview:_joinAndNoJoinView];
                [self addCellSeparator:64 cell:cell];
            }else if ( indexPath.section == 5  && indexPath.row == 0 ){
                cell.textLabel.text = activeEvent.enventDesc ;
                [self addCellSeparator:64 cell:cell];
            }else if ( indexPath.section == 7  && indexPath.row == 0 ){
                if (activeEvent.location && ![@"" isEqualToString:activeEvent.location]) {
                    NSDictionary * locationDic = (NSDictionary *)[activeEvent.location objectFromJSONString];
                    
                    _vMap.centerCoordinate = CLLocationCoordinate2DMake([[locationDic objectForKey:@"latitude"] doubleValue], [[locationDic objectForKey:@"longitude"] doubleValue]);
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = self.vMap.centerCoordinate;
                    annotation.title = [locationDic objectForKey:@"location"];
                    [self.vMap addAnnotation:annotation];
                    [cell addSubview:self.vMap];
                }
            }
           return cell;
         }else if (indexPath.section == 3||indexPath.section == 4 || indexPath.section == 6){
             UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStyleV1] ;
             if (!cell) {
                 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellStyleV1];
                 cell.selectionStyle = UITableViewCellSelectionStyleNone;
             }
             if ( indexPath.section == 3  && indexPath.row == 0 ){
                 [self addCellSeparator:2 cell:cell];
                 
                 UIImage *icon = [UIImage imageNamed:@"Alert_Hour"];
                 CGSize itemSize = CGSizeMake(20, 20);
                 UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
                 CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                 [icon drawInRect:imageRect];
                 cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
                 cell.textLabel.text = @"Time:" ;
                 if ([userId isEqualToString:self.activeEvent.createId]) {
                     cell.detailTextLabel.text = @"Confirm" ;
                 }else{
                     cell.detailTextLabel.text = @"Voting" ;
                 }
                 [self addCellSeparator:64 cell:cell];
             }else if ( indexPath.section == 6  && indexPath.row == 0 ){
                 cell.textLabel.text = @"Location:" ;
                 if(activeEvent.location && ![@"" isEqualToString:activeEvent.location]){
                    NSDictionary * locationDic = (NSDictionary *)[activeEvent.location objectFromJSONString];
                    
                    cell.detailTextLabel.text  =  [locationDic objectForKey:@"location"] ;
                 }else{
                     cell.detailTextLabel.text = @"No location" ;
                 }
                 [self addCellSeparator:64 cell:cell];
             }
             return cell;
         }
    }
    return nil;
}


-(void)addFriendsList:(UIButton *) sender {
    InviteesViewController * inviteesVc = [[InviteesViewController alloc] init];
    inviteesVc.navStyleType = NavStyleType_LeftModelOpen ;
    inviteesVc.eid = self.activeEvent.Id ;
    inviteesVc.joinArr    = joinArr ;
    inviteesVc.joinAllArr = selectFriendArr ;
    inviteesVc.delegate   = self ;
    NavigationController *navC = [[NavigationController alloc] initWithRootViewController:inviteesVc];
    navC.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navC.navigationBar setBarTintColor: RGB(39, 135, 237)];
    [self.navigationController presentViewController:navC animated:YES completion:nil];
}


-(void)inviteesViewController:(InviteesViewController *)inviteesViewController {
    [self refreshActiveEventData:self.activeEvent.Id] ;
    [inviteesViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *
 *重新刷新数据：网络 中
 */
-(void)refreshActiveEventData:(NSString *)eventId{
    ASIHTTPRequest * aEventRequest = [t_Network httpPostValue:@{@"method":@"getAllSocials",@"eid":eventId }.mutableCopy
                                                         Url:Go2_socials
                                                    Delegate:self
                                                         Tag:Go2_getOneSocials_Tag];
    [aEventRequest startSynchronous];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   // if ([userId isEqualToString:self.activeEvent.create] ) {//是自己创建的就不跳转咯......
        if ( indexPath.section == 3 && indexPath.row == 0 ) {
            if ( self.activeDestinationBlank ) {
                 self.activeDestinationBlank();
            }
        }
   // }
}

-(void)openModeMember:(UIGestureRecognizer *) gestureRecognizer{
    InviteesJoinOrReplyTableViewController * inviteesJoinOrReplyVC = [[InviteesJoinOrReplyTableViewController alloc] init];
    
    NSMutableArray * memberArr = @[].mutableCopy ;
    for (NSDictionary *memDic in self.activeEvent.invitees) {
        MemberDataModel * member = [MemberDataModel modelWithDictionary:memDic];
        [memberArr addObject:member];
    }
    inviteesJoinOrReplyVC.isOpenModel = YES ;
    inviteesJoinOrReplyVC.memberArr   = memberArr ;
    NavigationController *navC= [[NavigationController alloc] initWithRootViewController:inviteesJoinOrReplyVC];
     navC.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navC.navigationBar setBarTintColor: RGB(39, 135, 237)];
    [self presentViewController:navC animated:YES completion:nil];
}


-(void)addCellSeparator:(CGFloat) LocaltionY cell:(UITableViewCell *) cell{
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, LocaltionY-1, cell.frame.size.width -20, 1)];
    separator.backgroundColor = [UIColor colorWithHexString:@"eeecec"];
    [cell.contentView addSubview:separator];
}

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







-(MKMapView *)vMap{
    if (!_vMap) {
        _vMap = [[MKMapView alloc] initWithFrame:CGRectMake(10, 0,kScreen_Width-20, 160)];
        _vMap.delegate = self;
        _vMap.camera.altitude = 20;
        _vMap.showsBuildings = YES;
        _vMap.zoomEnabled = NO ;
        _vMap.scrollEnabled = NO ;
    }
    return _vMap;
}

-(UIScrollView *)fivScrollV{
    if (!_fivScrollV) {
         _fivScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 50, 64)];
        [_fivScrollV setShowsHorizontalScrollIndicator:NO];
        [_fivScrollV setShowsVerticalScrollIndicator:NO];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openModeMember:)];
        tapGesture.numberOfTapsRequired = 1 ;
        [_fivScrollV addGestureRecognizer:tapGesture];
    }
    return _fivScrollV ;
}

-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_addBtn setImage:[UIImage imageNamed:@"add_default"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addFriendsList:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn ;
}

-(UIButton *)joinBtn{
    if (!_joinBtn){
         _joinBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, kScreen_Width/2-40, 44)];
        [_joinBtn setTag:3];
        [_joinBtn setBackgroundImage:[UIImage imageNamed:@"Join_Grey"] forState:UIControlStateNormal];
        [_joinBtn setBackgroundImage:[UIImage imageNamed:@"Join_Rectangle"] forState:UIControlStateSelected];
        [_joinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinBtn ;
}

-(UIButton *)noJoinBtn{
    if (!_noJoinBtn) {
        _noJoinBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width/2+10, 0, 160-20, 44)];
        [_noJoinBtn setTag:4];
        [_noJoinBtn setBackgroundImage:[UIImage imageNamed:@"NotJoin_Grey"] forState:UIControlStateNormal];
        [_noJoinBtn setBackgroundImage:[UIImage imageNamed:@"NotJoiningRectangle"] forState:UIControlStateSelected];
        [_noJoinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noJoinBtn ;
}
@end
