//
//  InviteesViewController.m
//  Go2
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "InviteesViewController.h"
#import "FriendGroup.h"
#import "Friend.h"
#import "HeadView.h"
#import "FriendSearchViewController.h"
#import "UIImageView+WebCache.h"
#import "SetFriendTableViewCell.h"
//#import "PurposeEventTimeViewController.h"
#import "NewPurposeEventTimeViewController.h"
@interface InviteesViewController () <HeadViewDelegate,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
    UIButton *addBtn;
    NSMutableArray *_groupArr;
    NSMutableArray *_friendsArr;
    
    NSMutableArray *_selectFriendArr; //选择的好友
    
    NSMutableDictionary *_selectIndexPathDic; //用户选择的indexPath
    
    BOOL isSelect;
    
  // UILabel *titlelabel;
}

@end

@implementation InviteesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title =  @"0 Invitees" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTag:1];
    if (self.navStyleType == NavStyleType_LeftRightSame) {
         [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
         [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    }if (self.navStyleType == NavStyleType_LeftModelOpen) {
        [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
        //左边。。。添加按钮事件
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_tick"] forState:UIControlStateNormal] ;
        [rightBtn addTarget:self action:@selector(saveSelectFriendsData:) forControlEvents:UIControlEventTouchUpInside] ;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;

        
    }
    [leftBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    
    if (self.navStyleType == NavStyleType_LeftRightSame) {
            UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
            [rightBtn setTag:2];

           [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_right"] forState:UIControlStateNormal] ;
            [rightBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
            self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    }
    
    _selectFriendArr = [NSMutableArray arrayWithCapacity:0];
    _selectIndexPathDic = [NSMutableDictionary dictionaryWithCapacity:0];

    [self loadData];
    
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark 加载数据
- (void)loadData {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    ASIHTTPRequest *_friendGroups = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:self Tag:anyTime_GetFTlist_tag];
    [_friendGroups setDownloadCache:g_AppDelegate.anyTimeCache];
    [_friendGroups setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
    [_friendGroups setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [_friendGroups startAsynchronous];
}


#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responeStr = [request responseString];
    NSLog(@"%@", [request responseString]);
    id groupObj = [responeStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_GetFTlist_tag: {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            NSMutableArray *fgArray = [NSMutableArray array];
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSArray *groupArr = [groupObj objectForKey:@"data"];
                    for (NSDictionary *dic in groupArr) {
                        FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
                        [fgArray addObject:friendGroup];
                    }
                    _groupArr = fgArray;
                    
                    ASIHTTPRequest *_friend = [t_Network httpGet:nil Url:anyTime_GetFriendList Delegate:self Tag:anyTime_GetFriendList_tag];
                    [_friend setDownloadCache:g_AppDelegate.anyTimeCache];
                    [_friend setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
                    [_friend setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
                    [_friend startAsynchronous];
                    [_tableView reloadData];
                }
            }
        }
        break;
            
        case anyTime_GetFriendList_tag: {
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSDictionary *friendDic = [groupObj objectForKey:@"data"];
                    for (FriendGroup *fg in _groupArr) {
                        NSMutableArray *frArray = [NSMutableArray array];
                        NSArray *frArr = [friendDic objectForKey:[NSString stringWithFormat:@"%@", fg.Id]];
                        for (NSDictionary *dic in frArr) {
                            Friend *friend = [Friend friendWithDict:dic];
                            if (self.navStyleType == NavStyleType_LeftModelOpen||self.isEdit) {//编辑，修改
                                NSArray *tmpArr = [self.joinAllArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %i",[friend.fid intValue]]];
                                if (tmpArr.count>0) {
                                    [_selectFriendArr addObject:friend];
                                }
                            }
                            [frArray addObject:friend];
                        }
                        fg.friends = frArray;
                        [_tableView reloadData];
                    }
                }
                self.title = [NSString stringWithFormat:@"%i Invites",_selectFriendArr.count] ;// @"0 Invitees" ;
            }
        }
            break;
        case anyTime_AddEventMember_tag:{
            NSString *statusCode = [groupObj objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showSuccess:@"Success"];
                if (self.delegate && [self.delegate respondsToSelector:@selector(inviteesViewController:)]) {
                    [self.delegate inviteesViewController:self] ;
                }
            }else{
                [MBProgressHUD showError:@" Fail "];
            }

        } break ;
        default:
            break;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"Newwork error"];
    }
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
        __block FriendGroup *friendGroup = [[FriendGroup alloc] init];
        friendGroup.name = [alertView textFieldAtIndex:0].text;
        
        ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{ @"name": friendGroup.name }.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
        __block ASIHTTPRequest *groupsRequest  = addGroupsRequest;
        [addGroupsRequest setCompletionBlock: ^{//请求成功
            NSString *responseStr = [groupsRequest responseString];
            NSLog(@"%@", responseStr);
            id objGroup = [responseStr objectFromJSONString];
            if ([objGroup isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [objGroup objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSDictionary *tmpDic = [objGroup objectForKey:@"data"];
                    friendGroup = [friendGroup initWithDict:tmpDic];
                }
            }
        }];
        
        [addGroupsRequest setFailedBlock: ^{//请求失败
            NSLog(@"%@", [groupsRequest responseString]);
        }];
        
        [addGroupsRequest startAsynchronous];
        
        [_groupArr addObject:friendGroup];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FriendGroup *friendGroup = _groupArr[section];
    NSInteger count = friendGroup.isOpened ? friendGroup.friends.count : 0;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
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
        //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    FriendGroup *friendGroup = _groupArr[indexPath.section];
    Friend *friend = friendGroup.friends[indexPath.row];
    
    NSArray * tmpArr =  [_selectFriendArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == %@",friend.Id]];
    if (tmpArr.count > 0) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_tick"] ;
        cell.accessoryView = imageView;
        NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
        [_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
    }
    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
   // cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    
    cell.nickName.text = (friend.nickname==nil||[friend.nickname isEqualToString:@""]) ? friend.username:friend.nickname;
    
    cell.userNote.text = (friend.alias==nil||[friend.alias isEqualToString:@""])?friend.email:friend.alias;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeadView *headView = [[HeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    headView.delegate = self;
    headView.friendGroup = _groupArr[section];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
    SetFriendTableViewCell *stv = (SetFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(self.navStyleType == NavStyleType_LeftModelOpen){
        FriendGroup *friendGroup = _groupArr[indexPath.section];
        Friend *friend = friendGroup.friends[indexPath.row];
        NSArray *tmpArr = [self.joinArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %i",[friend.fid intValue]]];
        if (tmpArr.count > 0 ) {
            [MBProgressHUD showError:@"Has joined the cannot cancel"];
            return;
        }
    }
    if (![_selectIndexPathDic objectForKey:indexPathStr]) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_tick"] ;
        stv.accessoryView = imageView;
        FriendGroup *friendGroup = _groupArr[indexPath.section];
        Friend *friend = friendGroup.friends[indexPath.row];
        [_selectFriendArr addObject:friend];
        [_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
    } else {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
        stv.accessoryView = imageView;
        FriendGroup *friendGroup = _groupArr[indexPath.section];
        Friend *friend = friendGroup.friends[indexPath.row];
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
        [tmpArr addObject:@{@"uid":friend.fid}];
    }
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    ASIHTTPRequest *_inviteFriend = [t_Network httpPostValue:@{@"eid":self.eid,@"member":[tmpArr JSONString]}.mutableCopy Url:anyTime_AddEventMember Delegate:self Tag:anyTime_AddEventMember_tag];
    [_inviteFriend startAsynchronous];
    
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
        case 2:{//open ---> viewController
            if (self.navStyleType == NavStyleType_LeftRightSame) {
                if ( ! _selectFriendArr || _selectFriendArr.count<=0) {
                    [MBProgressHUD showError:@"Invite at least 1 friend to join your event"];
                    return ;
                }
                self.activeDataMode.activeFriendArr = _selectFriendArr ;
//                PurposeEventTimeViewController * purposeEventVC = [[PurposeEventTimeViewController alloc] init] ;
//                if (self.isEdit){
//                    purposeEventVC.isEdit = self.isEdit ;
//                    purposeEventVC.activeEvent = self.activeEvent ;
//                }
//                purposeEventVC.activeDataMode = self.activeDataMode ;
               
                NewPurposeEventTimeViewController * newPurpose = [[NewPurposeEventTimeViewController alloc] init];
                if (self.isEdit){
                    newPurpose.isEdit = self.isEdit ;
                    newPurpose.activeEvent = self.activeEvent ;
                }
                newPurpose.activeDataMode = self.activeDataMode ;
                [self.navigationController pushViewController:newPurpose animated:YES] ;
            }else if(self.navStyleType == NavStyleType_LeftModelOpen){
                
            }
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
    
}

@end
