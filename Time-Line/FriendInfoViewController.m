//
//  FriendInfoViewController.m
//  Time-Line
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "FriendGroup.h"
#import "Friend.h"
#import "HeadView.h"
#import "FriendSearchViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendInfoTableViewCell.h"
@interface FriendInfoViewController ()<HeadViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,ASIHTTPRequestDelegate>
{
    UIButton *addBtn ;
    NSMutableArray *_groupArr;
    NSMutableArray *_friendsArr;
}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation FriendInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, naviHigth, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-frame.origin.y) style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView] ;
    [self createAddFriendBtn];
}


#pragma mark -创建一个添加组或添加好友的按钮
-(void)createAddFriendBtn{
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake( kScreen_Width -65,kScreen_Height -130, 45, 45);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_default"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_press"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addNewFriendsAndGroups:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self.tableView reloadData];
}


#pragma mark 加载数据
- (void)loadData
{
    ASIHTTPRequest *_friendGroups = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:self Tag:anyTime_GetFTlist_tag];
    [_friendGroups setDownloadCache:g_AppDelegate.anyTimeCache] ;
    [_friendGroups setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy|ASIAskServerIfModifiedWhenStaleCachePolicy];
    [_friendGroups setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy] ;
    [_friendGroups startSynchronous];
    
    ASIHTTPRequest *_friend = [t_Network httpGet:nil Url:anyTime_GetFriendList Delegate:self Tag:anyTime_GetFriendList_tag];
    [_friend setDownloadCache:g_AppDelegate.anyTimeCache] ;
    [_friend setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy|ASIAskServerIfModifiedWhenStaleCachePolicy];
    [_friend setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy] ;
    [_friend startSynchronous];
}



- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responeStr = [request responseString];
    NSLog(@"%@",[request responseString]);
    id groupObj = [responeStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_GetFTlist_tag:{
            NSMutableArray *fgArray = [NSMutableArray array];
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSArray *groupArr = [groupObj objectForKey:@"data"];
                    for (NSDictionary *dic in groupArr) {
                        FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
                        [fgArray addObject:friendGroup];
                    }
                }
            }
            _groupArr = fgArray;
        }
            break;
        case anyTime_GetFriendList_tag:{
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSDictionary *friendDic = [groupObj objectForKey:@"data"];
                    for (FriendGroup *fg in _groupArr) {
                        NSMutableArray *frArray = [NSMutableArray array];
                        NSArray *frArr = [friendDic objectForKey:[NSString stringWithFormat:@"%@",fg.Id]];
                        for (NSDictionary *dic in frArr) {
                            Friend *friend = [Friend friendWithDict:dic];
                            friend.imgBig=[friend.imgBig stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                            friend.imgSmall=[friend.imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                            [frArray addObject:friend];
                        }
                        fg.friends=frArray;
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request{
    
    
}

/**
 *  添加组或朋友按钮的单击事件
 *
 *  @param sender
 */
-(void)addNewFriendsAndGroups:(UIButton *)sender{
    [UIView animateWithDuration:0.2f animations:nil completion:^(BOOL finished) {
        addBtn.hidden=YES;
    }];
    
    UIActionSheet *fgSheet = [[UIActionSheet alloc] initWithTitle:@"add Friends Or Groups" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Friends",@"Add Groups", nil];
    [fgSheet showInView:self.view];
}

#pragma mark -UIActionSheet的代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if(buttonIndex == 0){//add friends
        FriendSearchViewController *searchVc = [[FriendSearchViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:searchVc animated:NO completion:nil];
        
    }else if (buttonIndex == 1){//add groups
        UIAlertView *gAlertView = [[UIAlertView alloc] initWithTitle:@"Add Groups" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        gAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [gAlertView show];
    }
    addBtn.hidden = NO;
}


#pragma mark -UIAlertView的代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        __block FriendGroup  *friendGroup= [[FriendGroup alloc ] init];
        friendGroup.name=[alertView textFieldAtIndex:0].text;
        
         ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{@"name": friendGroup.name}.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
        __block ASIHTTPRequest *groupsRequest = addGroupsRequest;
        [addGroupsRequest setCompletionBlock:^{//请求成功
            NSString * responseStr = [groupsRequest responseString];
            NSLog(@"%@",responseStr);
            id objGroup = [responseStr objectFromJSONString];
            if ([objGroup isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [objGroup objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSDictionary * tmpDic = [objGroup objectForKey:@"data"];
                    friendGroup= [friendGroup initWithDict:tmpDic];
                }
            }
        }];
        
        [addGroupsRequest setFailedBlock:^{//请求失败
            NSLog(@"%@",[groupsRequest responseString]);
            
        }];
        
        [addGroupsRequest startAsynchronous];
        
        [_groupArr addObject:friendGroup];
        [self.tableView reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groupArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FriendGroup *friendGroup = _groupArr[section];
    NSInteger count = friendGroup.isOpened ? friendGroup.friends.count : 0;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = (FriendInfoTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
        //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    FriendGroup *friendGroup = _groupArr[indexPath.section];
    Friend *friend = friendGroup.friends[indexPath.row];
    
    NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",_urlStr);
    NSURL *url=[NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
    cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    cell.nickName.text = friend.nickname;
    cell.userNote.text = friend.alias;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeadView *headView = [[HeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    headView.delegate = self;
    headView.friendGroup = _groupArr[section];
    
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    ViewController *viewController = [[ViewController alloc] init];
    //    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)clickHeadView
{
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
