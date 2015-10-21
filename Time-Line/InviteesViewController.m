//
//  InviteesViewController.m
//  Go2
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//
#define startTime @"start"
#define endTime   @"end"
typedef NS_ENUM(NSInteger, AllowAddTime) {
    AllowAddTime_NO=0,
    AllowAddTime_YES=1
};

#import "InviteesViewController.h"
#import "FriendGroup.h"
#import "Friend.h"
#import "HeadView.h"
#import "FriendSearchViewController.h"
#import "UIImageView+WebCache.h"
#import "SetFriendTableViewCell.h"
//#import "PurposeEventTimeViewController.h"
//#import "NewPurposeEventTimeViewController.h"
@interface InviteesViewController () <HeadViewDelegate,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
    UIButton *addBtn;
    NSMutableArray *_groupArr;
    NSMutableArray *_friendsArr;
    
    NSMutableArray *_selectFriendArr; //选择的好友
    
    NSMutableDictionary *_selectIndexPathDic; //用户选择的indexPath
    
    BOOL isSelect;
    AllowAddTime  allowAddTime;
}

@property (nonatomic,strong) UIButton *leftBtn;
@property (nonatomic,strong) UIButton *rightBtn;
@end

@implementation InviteesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title =  @"0 Invitees" ;
    [self.leftBtn setTag:1];
    if (self.navStyleType == NavStyleType_LeftRightSame) {
         [self.leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
         [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    }if (self.navStyleType == NavStyleType_LeftModelOpen) {
        [self.leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
        
        [self.rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_tick"] forState:UIControlStateNormal] ;
        [self.rightBtn addTarget:self action:@selector(saveSelectFriendsData:) forControlEvents:UIControlEventTouchUpInside] ;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    }
    [self.leftBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    
    
    if (self.navStyleType == NavStyleType_LeftRightSame) {
           [self.rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
           [self.rightBtn setTag:2];
           [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_tick"] forState:UIControlStateNormal] ;
           [self.rightBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
           self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
           self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    }
    
    _selectFriendArr = [NSMutableArray arrayWithCapacity:0];
    _selectIndexPathDic = [NSMutableDictionary dictionaryWithCapacity:0];

    [self loadData];
    
  
}

-(UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectZero];

    }
    return _leftBtn ;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:CGRectZero];
    }
    return _rightBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark 加载数据
- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    ASIHTTPRequest *_friendGroups =  [t_Network httpGet:@{@"method":@"queryFriends"}.mutableCopy
                                                    Url:Go2_Friends
                                               Delegate:self
                                                    Tag:Go2_Friends_queryUser_Tag];
    
    [_friendGroups setDownloadCache:g_AppDelegate.anyTimeCache];
    [_friendGroups setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
    [_friendGroups setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [_friendGroups startAsynchronous];
}

#pragma mark -UIActionSheet的代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex; {
    if (buttonIndex == 0) {//add friends
        FriendSearchViewController *searchVc = [[FriendSearchViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:searchVc animated:NO completion:nil];
    }
    else if (buttonIndex == 1) {//add groups
        
    }
    addBtn.hidden = NO;
}


#pragma mark -UIAlertView的代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
//        __block FriendGroup *friendGroup = [[FriendGroup alloc] init];
//        friendGroup.name = [alertView textFieldAtIndex:0].text;
//        
//        ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{ @"name": friendGroup.name }.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
//        __block ASIHTTPRequest *groupsRequest  = addGroupsRequest;
//        [addGroupsRequest setCompletionBlock: ^{//请求成功
//            NSString *responseStr = [groupsRequest responseString];
//            NSLog(@"%@", responseStr);
//            id objGroup = [responseStr objectFromJSONString];
//            if ([objGroup isKindOfClass:[NSDictionary class]]) {
//                NSString *statusCode = [objGroup objectForKey:@"statusCode"];
//                if ([statusCode isEqualToString:@"1"]) {
//                    NSDictionary *tmpDic = [objGroup objectForKey:@"data"];
//                    friendGroup = [friendGroup initWithDict:tmpDic];
//                }
//            }
//        }];
//        
//        [addGroupsRequest setFailedBlock: ^{//请求失败
//            NSLog(@"%@", [groupsRequest responseString]);
//        }];
//        
//        [addGroupsRequest startAsynchronous];
//        
//        [_groupArr addObject:friendGroup];
//        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"setFriendcell";
    
    SetFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = (SetFriendTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SetFriendTableViewCell" owner:self options:nil] lastObject];
         UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
         cell.accessoryView = imageView ;
        imageView.center = cell.accessoryView.center ;
    }
    
    Friend  * friend = _groupArr[indexPath.row];

    
    NSArray * tmpArr =  [_selectFriendArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == %@",friend.Id]];
    if (tmpArr.count > 0) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image = [UIImage imageNamed:@"selecte_friend_tick"] ;
        cell.accessoryView = imageView;
        NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
        [_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
    }
    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, friend.thumbnail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
   // cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    
    cell.nickName.text = (friend.nickname==nil||[friend.nickname isEqualToString:@""]) ? friend.username:friend.nickname;
    
    cell.userNote.text = (friend.alias==nil||[friend.alias isEqualToString:@""])?friend.email:friend.alias;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
    SetFriendTableViewCell *stv = (SetFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(self.navStyleType == NavStyleType_LeftModelOpen){
        Friend  *friend = _groupArr[indexPath.row];
        NSArray *tmpArr = [self.joinArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %i",friend.Id]];
        if (tmpArr.count > 0 ) {
            [MBProgressHUD showError:@"Has joined the cannot cancel"];
            return;
        }
    }
    if (![_selectIndexPathDic objectForKey:indexPathStr]) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image = [UIImage imageNamed:@"selecte_friend_tick"] ;
        stv.accessoryView = imageView;
        Friend *friend = _groupArr[indexPath.row];
        [_selectFriendArr addObject:friend];
        [_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
    } else {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
        stv.accessoryView = imageView;
        Friend *friend = _groupArr[indexPath.row];
        [_selectFriendArr removeObject:friend];
        [_selectIndexPathDic removeObjectForKey:indexPathStr];
    }
 
    self.title = [NSString stringWithFormat:@"%i Invitees", _selectFriendArr.count];
}

- (void)clickHeadView {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)saveSelectFriendsData:(UIButton *)sender {
    NSMutableArray * tmpArr = [NSMutableArray array];
    for (Friend * friend in _selectFriendArr) {
        [tmpArr addObject:@{@"uid":friend.Id}];
    }
    if (tmpArr.count>0) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ASIHTTPRequest *_inviteFriend = [t_Network httpPostValue:@{@"method":@"invitee",@"eid":self.eid,@"uids":[tmpArr JSONString]}.mutableCopy
                                                             Url:Go2_socials
                                                        Delegate:self
                                                             Tag:Go2_AddEventMember_tag];
        [_inviteFriend startAsynchronous];

    }
    
}


-(void)backToEventDeatailsView:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{//
            if (self.navStyleType == NavStyleType_LeftRightSame) {
               [self.navigationController popViewControllerAnimated:YES];
            }else if(self.navStyleType == NavStyleType_LeftModelOpen){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }break;
        case 2:{
            if (self.navStyleType == NavStyleType_LeftRightSame) {
                if ( ! _selectFriendArr || _selectFriendArr.count<=0) {
                    [MBProgressHUD showError:@"Invite at least 1 friend to join your event"];
                    return ;
                }
                self.activeDataMode.activeFriendArr = _selectFriendArr ;
                [self saveEventData:sender];
            }else if(self.navStyleType == NavStyleType_LeftModelOpen){
                
            }
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
    
}

#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responeStr = [request responseString];
    NSLog(@"%@", [request responseString]);
    id groupObj = [responeStr objectFromJSONString];
    switch (request.tag) {
        case Go2_Friends_queryUser_Tag: {
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
                if ( statusCode == 1 ) {
                    NSArray * friendArr = [groupObj objectForKey:@"datas"];
                    
                    __block NSMutableArray *frArray = [NSMutableArray array];
                    [friendArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Friend * friend = [Friend modelWithDictionary:obj];
                        if (self.navStyleType == NavStyleType_LeftModelOpen||self.isEdit) {//编辑，修改
                            NSArray *tmpArr = [self.joinAllArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@",friend.Id]];
                            if (tmpArr.count>0) {
                                [_selectFriendArr addObject:friend];
                            }
                        }
                        [frArray addObject:friend];
                        
                    }];
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    _groupArr = frArray;
                    [_tableView reloadData];
                }
                self.title = [NSString stringWithFormat:@"%i Invites",_selectFriendArr.count] ;// @"0 Invitees" ;
            }
        }
            break;
        case Go2_AddEventMember_tag:{
            int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showSuccess:@"Success"];
                if (self.delegate && [self.delegate respondsToSelector:@selector(inviteesViewController:)]) {
                    [self.delegate inviteesViewController:self] ;
                }
            }else{
                [MBProgressHUD showError:@" Fail "];
                 [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
            
        } break ;
        case Go2_addSocials_Tag:
        {
            int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ( statusCode == 1 ) {
                id tmpData = [groupObj objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    if (self.activeDataMode.activeImg) {
                        NSDictionary *tmpDic = (NSDictionary *)tmpData;
                        NSString *activeId = [tmpDic objectForKey:@"id"];
                        [self upLoadEventImage:activeId];
                    }else{
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        [MBProgressHUD showSuccess:@"Operation Success"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }else {
                [MBProgressHUD showError:[groupObj objectForKey:@"message"]];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        }
            break;
        case Go2_UpdateEvents_tag:{
            int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ( statusCode  == 1 ) {
                id tmpData = [groupObj objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    if (self.activeDataMode.activeImg) {
                        [self upLoadEventImage:self.activeDataMode.Id];
                    }else{
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        [MBProgressHUD showSuccess:@"Operation Success"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }
        }break;

        default:
            break;
    }
}

-(void)upLoadEventImage:(NSString *)eid {
    //上传活动图片
    NSURL * url = [NSURL URLWithString:[Go2_UploadSocialFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIFormDataRequest * uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
    [uploadImageRequest setRequestMethod:@"POST"];
    [uploadImageRequest setPostValue:eid    forKey:@"eid"];
    [uploadImageRequest setPostValue:@"img" forKey:@"type"];
    NSData *data = UIImagePNGRepresentation(self.activeDataMode.activeImg);
    NSMutableData *imageData = [NSMutableData dataWithData:data];
    [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
    [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
    NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
    
    [uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
    [uploadImageRequest setTag:Go2_UploadSocialFile_Tag];
    __block ASIFormDataRequest *uploadRequest = uploadImageRequest;
    [uploadImageRequest setCompletionBlock: ^{
        NSString *responseStr = [uploadRequest responseString];
        NSLog(@"数据更新成功：%@", responseStr);
        id obj = [responseStr objectFromJSONString];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)obj;
            int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
            if ( statusCode == 1 ) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [MBProgressHUD showSuccess:@"Operation Success"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
    [uploadImageRequest setFailedBlock: ^{
        NSLog(@"请求失败：%@", [uploadRequest responseString]);
        [MBProgressHUD showError:@"Please connect to the Internet"];
    }];
    [uploadImageRequest startAsynchronous];
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"Newwork error"];
    }
}


-(void)saveEventData:(UIButton *)sender {
    if (self.isEdit) {
        NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];
        [activeDic setObject:self.activeDataMode.Id                forKey:@"id"];
        [activeDic setObject:self.activeEvent.createId             forKey:@"create"];//创建者的id
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        if (self.activeDataMode.activeLocName && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:[@{@"location":self.activeDataMode.activeLocName==nil?@"":self.activeDataMode.activeLocName,
                                    @"latitude":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],
                                    @"longitude":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE],@"description":@""
                                    } JSONString]
                          forKey:@"location"];
            
        }
        if (self.activeDataMode.activeDesc &&  ! [@"" isEqualToString:self.activeDataMode.activeDesc]) {
            [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"description"];
        }
        
        [activeDic setObject:@(allowAddTime)                       forKey:@"canProposeTime"];
        
        NSMutableArray * tmpAddArr = [NSMutableArray array];//存放已经添加的人员
        //找到要添加的人员-----------------start----------------
        NSMutableArray * tmpAddingArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeFriendArr];//存放要添加的人员
        for (Friend *friend in self.activeDataMode.activeFriendArr) {//成员比较那些是添加的人员，那些是删除的人员
            for (NSDictionary *tmpDic in self.activeEvent.invitees) {
                NSString * uid = [tmpDic objectForKey:@"uid"];
                if ( [ friend.Id isEqualToString:uid ] ) {
                    [tmpAddingArr removeObject:friend];//存放要添加的人员中移除已经添加的人员
                    [tmpAddArr addObject:friend];
                    break;
                }
            }
        }
        NSMutableArray *addFriendIds = @[].mutableCopy ;
        for (Friend *friend in tmpAddingArr) {
            [addFriendIds addObject:@{@"uid":friend.Id}];
        }
        
        if(addFriendIds.count>0){
            [activeDic setObject:[addFriendIds JSONString] forKey:@"invitees"];
        }
        //-----------------------------end---------------------
        
        //找到要删除的人员----------------start------------------
        NSMutableArray * tmpDelingArr = [NSMutableArray arrayWithArray:self.activeEvent.invitees];//存放要添加的人员
        for (NSDictionary *tmpDic in self.activeEvent.invitees) {//成员比较那些是要铲除的人员
            NSString * uid = [tmpDic objectForKey:@"uid"];
            for (Friend *friend  in tmpAddArr) {
                if ( [ friend.Id isEqualToString:uid ] ) {
                    [tmpDelingArr removeObject:tmpDic];
                    break;
                }
            }
        }
        
        NSMutableArray *delFriendIds = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpDelingArr) {
            NSString * fid = [tmpDic objectForKey:@"uid"] ;
            if (![fid isEqualToString:[UserInfo currUserInfo].Id]) {//排除自己
                [delFriendIds addObject:@{ @"uid":fid }];
            }
        }
        
        if (delFriendIds.count > 0) {
            [activeDic setObject:[delFriendIds JSONString] forKey:@"deleteInvitees"];
        }
        //-----------------------------end---------------------
        
        //找到新增的时间-------------------start----------------
        NSMutableArray * timeAddArr = [NSMutableArray array];
        NSMutableArray * tmpAddTimeArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeVoteDate];
        
        for (NSDictionary  *timeDic in self.activeDataMode.activeVoteDate) {
            for (NSDictionary *tmpDic in self.activeEvent.proposeTimes) {
                NSString * timeId = [tmpDic objectForKey:@"id"];
                if ( [timeId isEqualToString: [timeDic objectForKey:@"id"]] ) {
                    [tmpAddTimeArr removeObject:timeDic];
                    [timeAddArr addObject:timeDic];
                    break;
                }
            }
        }
        NSMutableArray *addTimeArr = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpAddTimeArr) {
            NSDate *startDate = [tmpDic objectForKey:startTime];
            NSString *start = [self getUTCFormateLocalDate:startDate];
            
            NSDate *endDate = [tmpDic objectForKey:endTime];
            NSString *end = [self getUTCFormateLocalDate:endDate];
            [addTimeArr  addObject:@{@"start":start,@"end":end,@"isAllday":@(0) }];
        }
        [activeDic setObject:@(0) forKey:@"status"];
        if(addTimeArr.count>0){
            [activeDic setObject:[addTimeArr JSONString]forKey:@"proposeTimes"];
        }
        //-----------------------------end----------------
        
        NSMutableArray * tmpDeleteTimeArr = [NSMutableArray arrayWithArray:self.activeEvent.proposeTimes];
        for (NSDictionary  *timeDic in self.activeEvent.proposeTimes) {
            for (NSDictionary *tmpDic in self.activeDataMode.activeVoteDate) {
                NSString * timeId = [tmpDic objectForKey:@"id"];
                if ( [timeId isEqualToString: [timeDic objectForKey:@"id"]] ) {
                    [tmpDeleteTimeArr removeObject:timeDic];
                    break;
                }
            }
        }
        
        if(tmpDeleteTimeArr.count>0){
            NSMutableArray *delTimeIds = @[].mutableCopy ;
            for (NSDictionary *tmpDic in tmpDeleteTimeArr) {
                NSString * tid = [tmpDic objectForKey:@"id"] ;
                [delTimeIds addObject:@{ @"id":tid }];
            }
            
            [activeDic setObject:[delTimeIds JSONString]forKey:@"deleteTimes"];
        }
        
        
        if (self.activeDataMode.activeCoordinate) {
            [activeDic setObject:[NSString stringWithFormat:@"%@;%@",[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]] forKey:@"coordinate"] ;
        }
        [activeDic setObject:@"updateSocial" forKey:@"method"];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:Go2_socials Delegate:self Tag:Go2_UpdateEvents_tag];
        [addActiveRequest startAsynchronous];
        
    }else{//新增event
        NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        
        //location={"location":"地址"，"latitude":"纬度","longitude":"经度","description":"地址详细描述"}
        if (self.activeDataMode.activeLocName!=nil && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:[@{@"location":self.activeDataMode.activeLocName==nil?@"":self.activeDataMode.activeLocName,
                                    @"latitude":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],
                                    @"longitude":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE],@"description":@""
                                    } JSONString]
                          forKey:@"location"];
        }
        
        if (self.activeDataMode.activeDesc && ![@"" isEqualToString:self.activeDataMode.activeDesc]) {
            [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"description"];
        }
        
        [activeDic setObject:@(allowAddTime)          forKey:@"canProposeTime"];
        
        NSMutableArray *voteDateArr = @[].mutableCopy ;
        
        for (NSDictionary * dic in self.activeDataMode.activeVoteDate) {
            NSDate *startDate = [dic objectForKey:startTime];
            NSString *start = [self getUTCFormateLocalDate:startDate];
            
            NSDate *endDate = [dic objectForKey:endTime];
            NSString *end = [self getUTCFormateLocalDate:endDate];
            [voteDateArr addObject:@{@"start":start,@"end":end,@"isAllday":@(0)}];
        }
        
        [activeDic setObject:[voteDateArr JSONString] forKey:@"proposeTimes"];
        
        NSMutableArray *inviteeArr = @[@{@"uid":[UserInfo currUserInfo].Id}].mutableCopy;
        for (Friend * friend in self.activeDataMode.activeFriendArr) {
            [inviteeArr addObject:@{@"uid":friend.Id}];
        }
        
        [activeDic setObject:[inviteeArr JSONString] forKey:@"invitees"];
        [activeDic setObject:@"add" forKey:@"method"];
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:Go2_socials Delegate:self Tag:Go2_addSocials_Tag];
        [addActiveRequest startAsynchronous];
    }
    
}

#pragma marke - 格式化时间Date
- (NSString *)toStringFromDate:(NSString *)format formaterDate:(NSDate *) date {
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSString *loctime = [formatter stringFromDate:date];
    NSLog(@"%@", loctime);
    return loctime;
    
}

-(NSString *)getUTCFormateLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}


@end
