//
//  FriendsProfilesTableViewController.m
//  Go2
//
//  Created by IF on 15/3/16.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "FriendsProfilesTableViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendGroup.h"
#import "AcceptFriendTableViewCell.h"




@interface FriendsProfilesTableViewController (){
    ShowButtonType showButtonType;
}
@property (nonatomic , retain) NSMutableArray  * dataArr ;
@property (nonatomic , retain) NSMutableArray  * arrayList ;
@property (nonatomic , retain) NSIndexPath     * lastIndexPath ;
@property (nonatomic , assign) BOOL              isSelect;
@property (nonatomic , retain) NSDictionary    * messageDic;
@end

@implementation FriendsProfilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Friend's Profile" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToInvitationsView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    _arrayList = [NSMutableArray arrayWithCapacity:0] ;
    
    
    self.messageDic = self.noticesMsg.message ;
    
    if (self.isSendRequest) {
        _dataArr = [NSMutableArray arrayWithObjects:self.friend,_arrayList, nil] ;
        showButtonType = ShowButtonType_Add ;
        [self loadFriendGroupData];
        return;
    }
    
     showButtonType = ShowButtonType_Accept ;
    _dataArr = [NSMutableArray arrayWithObjects:self.messageDic,_arrayList, nil] ;
    
    if (self.isAddSuccess) {//如果已是好友关系就直接加载组的数据
        showButtonType = ShowButtonType_Friend ;
        [self loadFriendGroupData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0) {
        return 2 ;
    }else if( section == 1 ){
        NSArray * tmpArr = (NSArray *)_dataArr[section] ;
         return tmpArr.count;
    }
    return 0 ;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 ) {
            return 90.f ;
        }else{
            return 64.f ;
        }
        
    }else{
        return 44.f ;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1.0f;
    }else{
        return 50.f;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 ) {
        NSArray * tmpArr = self.dataArr[section];
        if (tmpArr.count>0) {
            UILabel * headLab = [[UILabel alloc] initWithFrame:CGRectMake(2, 27, 100, 20)];
            [headLab setBackgroundColor:[UIColor clearColor]];
            [headLab setTextColor:[UIColor grayColor]];
            [headLab setText:@" Belongs to:"];
            
            UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
            [sectionView setBackgroundColor:[UIColor clearColor]];
            [sectionView addSubview:headLab];
            return sectionView ;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if ( indexPath.row == 0){
            static NSString *activeCellID = @"activeMsgCellId";
            AcceptFriendTableViewCell *activeCell = [tableView dequeueReusableCellWithIdentifier:activeCellID ];
            if (!activeCell) {
                activeCell = (AcceptFriendTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"AcceptFriendTableViewCell" owner:self options:nil] firstObject];
            }
            if (self.isSendRequest) {
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, self.friend.imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@", _urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [activeCell.userHeadImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                [activeCell.userName setTextColor: defineBlueColor];
                [activeCell.userName setText:self.friend.username];
                [activeCell.userAlias setText:self.friend.alias==nil? self.friend.email:self.friend.alias]  ;

            }else{
                NSString *tmpUrl = [[self.messageDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@", _urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [activeCell.userHeadImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                [activeCell.userName setTextColor: defineBlueColor];
                [activeCell.userName setText:[self.messageDic objectForKey:@"fname"]];
                
                [activeCell.userAlias setText:[self.messageDic objectForKey:@"msg"]]  ;
            }
            return  activeCell ;
        }else if (indexPath.row == 1){
            static NSString *addCellId = @"addCellId";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellId ] ;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            }
            NSArray *subviews = [[NSArray alloc]initWithArray:cell.contentView.subviews];
            for (UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
            UIButton * acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [acceptBtn setFrame:CGRectMake((kScreen_Width-260)/2, 12, 260, 40)];
            [acceptBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            acceptBtn.layer.cornerRadius = 5 ;
            acceptBtn.layer.masksToBounds = YES;
//            if (!self.isSendRequest) {
//                if (!self.isAddSuccess) {
//                    showButtonType = ShowButtonType_Accept;
//                }else{
//                    showButtonType = ShowButtonType_Friend;
//                }
//            }else{
//                showButtonType = ShowButtonType_Add ;
//            }
            switch (showButtonType) {
                case ShowButtonType_Accept:{
                    [acceptBtn setTitleColor:defineBlueColor forState:UIControlStateNormal] ;
                    [acceptBtn setTitle:@"Acccept Friend Request" forState:UIControlStateNormal] ;
                    [acceptBtn.layer setBorderColor:defineBlueColor.CGColor];
                    [acceptBtn.layer setBorderWidth:2.f];
                    [acceptBtn addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
                }break;
                case ShowButtonType_Friend:{
                    [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
                    [acceptBtn setTitle:@"Friend" forState:UIControlStateNormal] ;
                    [acceptBtn setBackgroundColor:defineBlueColor];
                    [acceptBtn addTarget:self action:@selector(relieveFriendRelationship:) forControlEvents:UIControlEventTouchUpInside];

                }break ;
                case ShowButtonType_Add:{
                    [acceptBtn setTitleColor:defineBlueColor forState:UIControlStateNormal] ;
                    [acceptBtn setTitle:@"Add as friend" forState:UIControlStateNormal] ;
                    [acceptBtn.layer setBorderColor:defineBlueColor.CGColor];
                    [acceptBtn.layer setBorderWidth:2.f];
                    [acceptBtn addTarget:self action:@selector(addFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
                }break ;
                case ShowButtonType_Send:{
                    [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
                    [acceptBtn setTitle:@"Friend Request Sent" forState:UIControlStateNormal] ;
                    [acceptBtn setBackgroundColor:[UIColor redColor]];
                }break ;
                default:
                    break;
            }
            [cell.contentView addSubview:acceptBtn];
            return   cell;
        }
    }else{
        static NSString *addCellId = @"addCellFGroup";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellId ] ;
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        }
        if (!self.isSelect ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPath = indexPath;
            self.isSelect = YES;
            if (!self.isAddSuccess && !self.isSendRequest) {
                [self addFriendRequest];//添加到默认组
            }
        }

        NSArray * tmpArr = self.dataArr[indexPath.section];
        FriendGroup * fgroup = tmpArr[indexPath.row] ;
        cell.textLabel.text =fgroup.name;
        return   cell;
    }
    return nil ;
}

-(void)acceptFriendRequest:(UIButton *) sender{
    [self loadFriendGroupData];
}

#pragma mark - 解除好友关系 ---delete
-(void)relieveFriendRelationship:(UIButton *) sender{
//    ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":[self.messageDic objectForKey:@"fid"], @"fname":[self.messageDic objectForKey:@"fname"], @"mid":self.noticesMsg.Id, @"type":@(1) }.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];
//
//        __block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
//        [acceptFriendRequest setCompletionBlock: ^{
//            NSString *responseStr = [acceptRequest responseString];
//            id obtTmp =  [responseStr objectFromJSONString];
//            if ([obtTmp isKindOfClass:[NSDictionary class]]) {
//                NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
//                if ([statusCode isEqualToString:@"1"]) {
//                    [MBProgressHUD showSuccess:@"Success"];
//                }
//            }
//        }];
//
//        [acceptFriendRequest setFailedBlock: ^{
//            [MBProgressHUD showError:@"Network error"];
//        }];
//        [acceptFriendRequest startAsynchronous];
    
    ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":[self.messageDic objectForKey:@"fid"], @"fname":[self.messageDic objectForKey:@"fname"] }.mutableCopy Url:anyTime_DeleteFriend Delegate:nil Tag:anyTime_DeleteFriend_tag];
    __block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
    [acceptFriendRequest setCompletionBlock: ^{
        NSString *responseStr = [acceptRequest responseString];
        id obtTmp =  [responseStr objectFromJSONString];
        if ([obtTmp isKindOfClass:[NSDictionary class]]) {
            NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                
                [MBProgressHUD showSuccess:@"Delete success"];
                
            }
            showButtonType = ShowButtonType_Add ;
            [self.tableView reloadData] ;
        }
    }];
    
    [acceptFriendRequest setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error"];
    }];
    [acceptFriendRequest startAsynchronous];

}


-(void)loadFriendGroupData{
    if ([self.arrayList count]<=0) {
        ASIHTTPRequest *request = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:nil Tag:anyTime_GetFTlist_tag];
        __block ASIHTTPRequest *getFRequest = request ;
        [request setCompletionBlock:^{
            NSString *responeStr = [getFRequest responseString];
            NSLog(@"%@",[getFRequest responseString]);
            id groupObj = [responeStr objectFromJSONString];
            [self.arrayList removeAllObjects];
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSArray *groupArr = [groupObj objectForKey:@"data"];
                    for (NSDictionary *dic in groupArr) {
                        FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
                        [self.arrayList addObject:friendGroup];
                    }
                    [self.dataArr addObject:self.arrayList];
                }
            }
        }];
        
        [request setFailedBlock:^{
            NSLog(@"%@",[getFRequest error]);
            [MBProgressHUD showError:@"Error"];
        }];
        [request startSynchronous];
        [self.tableView reloadData];
    }
}


-(void)addFriendRequest{
      NSArray * tmpArr = self.dataArr[self.lastIndexPath.section];
      FriendGroup * fgroup = tmpArr[self.lastIndexPath.row] ;
    
      ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":[self.messageDic objectForKey:@"fid"], @"tid":fgroup.Id, @"fname":[self.messageDic objectForKey:@"fname"], @"mid":self.noticesMsg.Id }.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];

        __block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
        [acceptFriendRequest setCompletionBlock: ^{
            NSString *responseStr = [acceptRequest responseString];
            id obtTmp =  [responseStr objectFromJSONString];
            if ([obtTmp isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    self.isAddSuccess = YES ;
                    showButtonType = ShowButtonType_Friend;
                    [self.tableView reloadData];
                    [MBProgressHUD showSuccess:@"Success"];
                }
            }
        }];
        [acceptFriendRequest setFailedBlock: ^{
            [MBProgressHUD showError:@"Network error"];
        }];
        [acceptFriendRequest startAsynchronous];
}

-(void)addFriendRequest:(UIButton *)sender {
    if (self.friendsAddProfileblack) {
        NSArray * tmpArr = self.dataArr[self.lastIndexPath.section];
        FriendGroup * fgroup = tmpArr[self.lastIndexPath.row] ;
        self.friendsAddProfileblack(fgroup.Id);
        showButtonType = ShowButtonType_Send;
        [self.tableView reloadData];
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES] ;
    if (indexPath.section == 1) {
        int newRow = [indexPath row];
        int oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;
        
        int newSection = [indexPath section];
        int oldSection = (self.lastIndexPath != nil) ? [self.lastIndexPath section] : -1;
        
        newRow = [[NSString stringWithFormat:@"%d%d", newSection, newRow] intValue];
        oldRow = [[NSString stringWithFormat:@"%d%d", oldSection, oldRow] intValue];
        if (newRow != oldRow) {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.lastIndexPath = [indexPath copy];
            if (!self.isSendRequest) {
                if(self.isAddSuccess){ //当发送朋友isSendRequest为NO 并且 isAddsuccess-->yes 添加成功以后才能点击一次更新一次
                    [self updateUserOfGroup]; //更新用户所在组
                }
            }
        }
    }
}

-(void)updateUserOfGroup{
    NSArray * tmpArr = self.dataArr[self.lastIndexPath.section];
    FriendGroup * fgroup = tmpArr[self.lastIndexPath.row] ;
    ASIHTTPRequest *updateFriendTRequest = [t_Network httpPostValue:@{ @"fid":[self.messageDic objectForKey:@"fid"], @"tid":fgroup.Id }.mutableCopy Url:anyTime_UpdateFTeam Delegate:nil Tag:anyTime_UpdateFTeam_tag];
    __block ASIHTTPRequest *updateRequest = updateFriendTRequest;
    [updateFriendTRequest setCompletionBlock: ^{
        NSString *responseStr = [updateRequest responseString];
        id obtTmp =  [responseStr objectFromJSONString];
        if ([obtTmp isKindOfClass:[NSDictionary class]]) {
            NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                NSLog(@">>>>>>>>>>>>>>>>>>Team update success");
            }
        }
    }];
    [updateFriendTRequest setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error"];
    }];
    [updateFriendTRequest startAsynchronous];
}


-(void)backToInvitationsView{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
