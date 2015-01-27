//
//  NoticesViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticesViewController.h"
#import "MJRefresh.h"
#import "ActiveTableViewCell.h"
#import "UserApplyTableViewCell.h"
#import "NotiveMsgPageBaseMode.h"
#import "NoticesMsgModel.h"
#import "UIImageView+WebCache.h"
#import "FriendGroupShowViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface NoticesViewController ()<UITableViewDataSource,UITableViewDelegate,UserApplyTableViewCellDelegate>{
    
    NSMutableArray * _noticeArr;
    NSInteger currPageNum ; //当前页码

}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation NoticesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    _noticeArr = [NSMutableArray array];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-naviHigth) style:UITableViewStyleGrouped];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self setupRefresh] ;

}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"noticeView"];
    
    [self.tableView headerBeginRefreshing];
    
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}


#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [_noticeArr removeAllObjects];
    [self loadUserRequestInfo:1];
    [self.tableView headerEndRefreshing];
}

- (void)footerRereshing
{
    currPageNum = currPageNum+1 ;
    [self loadUserRequestInfo:currPageNum+1];
    [self.tableView footerEndRefreshing];
}


-(void)loadUserRequestInfo:(NSInteger )num{
    ASIHTTPRequest  *msgRequest = [t_Network httpGet:@{@"num":@(num)}.mutableCopy Url:anyTime_GetUserMessage2 Delegate:nil Tag:anyTime_GetUserMessage2_tag];
    [msgRequest setDownloadCache:g_AppDelegate.anyTimeCache] ;
    [msgRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy|ASIAskServerIfModifiedWhenStaleCachePolicy];
    [msgRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy] ;
    __block ASIHTTPRequest * msgReq = msgRequest ;
    [msgRequest setCompletionBlock:^{
        NSString * responseStr = [msgReq responseString] ;
        id  objTmp =  [responseStr objectFromJSONString];
        if ([objTmp isKindOfClass:[NSDictionary class]]) {
            NSDictionary * objDic = (NSDictionary *) objTmp ;
            NSString * statusCode = [objDic objectForKey:@"statusCode"] ;
            if ([statusCode isEqualToString:@"1"]) {
                 id dataDic = [objDic objectForKey:@"data"];
                if ([dataDic isKindOfClass:[NSDictionary class]]) {
                    NotiveMsgPageBaseMode  * notiveMsgPage = [NotiveMsgPageBaseMode new];
                    [notiveMsgPage parseDictionary:dataDic];
                    if ( notiveMsgPage.records ) {
                        for (NSDictionary *dic in notiveMsgPage.records) {
                            NSLog(@"%@",dic);
                            NoticesMsgModel *noticeMsg = [NoticesMsgModel new];
                            [noticeMsg parseDictionary:dic] ;
                            [_noticeArr addObject:noticeMsg];
                        }
                    }
                }
                [_tableView reloadData] ; //刷新table
            }else{
            
            }
        }
    }];
    
    [msgRequest setFailedBlock:^{
        [MBProgressHUD showError:@"Network error!"];
    }];
    
    [msgRequest startAsynchronous];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return _noticeArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoticesMsgModel * noticeMsg = [_noticeArr objectAtIndex:indexPath.section];
    if ([noticeMsg.type integerValue]<10) {
        return 110.f;
    }else{
        return 215.f;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoticesMsgModel * noticeMsg = [_noticeArr objectAtIndex:indexPath.section];
    if ([noticeMsg.type integerValue]<10) {
        static NSString *activeId=@"activeCellId";
        UserApplyTableViewCell *userApplyCell=[tableView dequeueReusableCellWithIdentifier:activeId];
        if (!userApplyCell) {
            userApplyCell = (UserApplyTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"UserApplyTableViewCell" owner:self options:nil] firstObject];
        }
        if ([noticeMsg.type integerValue] == 1) { //好友请求
             NSDictionary * msgDic =  noticeMsg.message ;
            if (msgDic) {
                [userApplyCell setNoticesMsg:noticeMsg] ; //设置信息
                userApplyCell.delegate = self ;
                
                NSString * tmpUrl = [[msgDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@",BASEURL_IP,tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@",_urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [userApplyCell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
                [userApplyCell setFriendRequestInfo:[msgDic objectForKey:@"msg"]] ;
            }
        }else if ([noticeMsg.type integerValue] == 2) {//对方同意/no 信息

            NSDictionary * msgDic =  noticeMsg.message ;
            [userApplyCell.acceptBtn setHidden:YES];
            [userApplyCell.denyBtn   setHidden:YES] ;
            if (msgDic) {
                NSString * tmpUrl = [[msgDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@",BASEURL_IP,tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@",_urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [userApplyCell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
                [userApplyCell setFriendRequestInfo:[msgDic objectForKey:@"msg"]] ;
            }
        }
        return userApplyCell;
    }else{
        static NSString *activeCellID=@"activeManagerCellId";
        ActiveTableViewCell *activeCell=[tableView dequeueReusableCellWithIdentifier:activeCellID];
        if (!activeCell) {
            activeCell = (ActiveTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ActiveTableViewCell" owner:self options:nil] firstObject];
        }
        if ([noticeMsg.type integerValue] == 10) {
            NSDictionary * msgDic = noticeMsg.message ;
            
        }
        return activeCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)userApplyTableViewCell:(UserApplyTableViewCell *)selfCell paramNoticesMsgModel:(NoticesMsgModel *)noticesMsg isAcceptAndDeny:(BOOL)isAccept{
    NSDictionary  * paramDic = noticesMsg.message ;
    if (!isAccept) {//表示用户不同意添加对方为好友
        ASIHTTPRequest * acceptFriendRequest = [t_Network httpPostValue:@{@"fid":[paramDic objectForKey:@"fid"],@"fname":[paramDic objectForKey:@"fname"],@"mid":noticesMsg.Id,@"type":@(1)}.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];
        
        __block  ASIHTTPRequest * acceptRequest = acceptFriendRequest ;
        [acceptFriendRequest setCompletionBlock:^{
            NSString * responseStr = [acceptRequest responseString];
            id  obtTmp =  [responseStr objectFromJSONString];
            if([obtTmp isKindOfClass:[NSDictionary class]]){
                NSString * statusCode = [obtTmp objectForKey:@"statusCode"] ;
                if ([statusCode isEqualToString:@"1"]) {
                    selfCell.acceptBtn.hidden = YES ;
                    selfCell.denyBtn.hidden   = YES ;
                    [MBProgressHUD showSuccess:@"Success"];
                }
            }
        }];
        
        [acceptFriendRequest setFailedBlock:^{
            [MBProgressHUD showError:@"Network error"];
            
        }];
        [acceptFriendRequest startAsynchronous];
        
        return;
    }
    
    FriendGroupShowViewController *fgsVC = [[FriendGroupShowViewController alloc] initWithNibName:@"FriendGroupShowViewController" bundle:nil];

    fgsVC.fBlock = ^(FriendGroupShowViewController * selfViewController,FriendGroup *friendGroup){
        
        ASIHTTPRequest * acceptFriendRequest = [t_Network httpPostValue:@{@"fid":[paramDic objectForKey:@"fid"],@"tid":friendGroup.Id,@"fname":[paramDic objectForKey:@"fname"],@"mid":noticesMsg.Id}.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];
    
       __block  ASIHTTPRequest * acceptRequest = acceptFriendRequest ;
        [acceptFriendRequest setCompletionBlock:^{
            NSString * responseStr = [acceptRequest responseString];
            id  obtTmp =  [responseStr objectFromJSONString];
            if([obtTmp isKindOfClass:[NSDictionary class]]){
                NSString * statusCode = [obtTmp objectForKey:@"statusCode"] ;
                if ([statusCode isEqualToString:@"1"]) {
                    
                    selfCell.acceptBtn.hidden = YES ;
                    selfCell.denyBtn.hidden   = YES ;
                   [selfViewController dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade] ;
                   [MBProgressHUD showSuccess:@"Success"];
                }
            }
        }];
        [acceptFriendRequest setFailedBlock:^{
            [MBProgressHUD showError:@"Network error"];
        }];
        [acceptFriendRequest startAsynchronous];
    };
    [self presentPopupViewController:fgsVC animationType:MJPopupViewAnimationFade];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NoticesMsgModel *noticesMsgModel = [_noticeArr objectAtIndex:indexPath.section] ;
        ASIHTTPRequest * deleteMsgRequest = [t_Network httpPostValue:@{@"msgId":[@[@{@"id":noticesMsgModel.Id}] JSONString]}.mutableCopy Url:anyTime_DelMessage Delegate:nil Tag:anyTime_DelMessage_tag];
        
                           __block  ASIHTTPRequest * magRequest = deleteMsgRequest ;
        [deleteMsgRequest setCompletionBlock:^{
            NSString * responseStr = [magRequest responseString];
            id  obtTmp =  [responseStr objectFromJSONString];
            if([obtTmp isKindOfClass:[NSDictionary class]]){
                NSString * statusCode = [obtTmp objectForKey:@"statusCode"] ;
                if ([statusCode isEqualToString:@"1"]) {
                    [_noticeArr removeObjectAtIndex:indexPath.section];
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                    [MBProgressHUD showSuccess:@"Success"];
                }else{
                    [MBProgressHUD showError:@"Delete failed"];
                }
            }
        }];
        [deleteMsgRequest setFailedBlock:^{
            [MBProgressHUD showError:@"Network error"];
        }];
        [deleteMsgRequest startAsynchronous];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
     
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

@end
