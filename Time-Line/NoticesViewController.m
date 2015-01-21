//
//  NoticesViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticesViewController.h"
#import "ActiveTableViewCell.h"
#import "UserApplyTableViewCell.h"
#import "NoticesMsgModel.h"
#import "UIImageView+WebCache.h"


@interface NoticesViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray * _noticeArr;

}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation NoticesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, naviHigth, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    _noticeArr = [NSMutableArray array];
    
    [self loadUserRequestInfo];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-frame.origin.y) style:UITableViewStyleGrouped];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
}

-(void)loadUserRequestInfo{
    ASIHTTPRequest  *msgRequest = [t_Network httpGet:nil Url:anyTime_GetUserMessage Delegate:nil Tag:anyTime_GetUserMessage_tag];
    __block ASIHTTPRequest * msgReq = msgRequest ;
    [msgRequest setCompletionBlock:^{
        NSString * responseStr = [msgReq responseString] ;
        id  objTmp =  [responseStr objectFromJSONString];
        if ([objTmp isKindOfClass:[NSDictionary class]]) {
            NSDictionary * objDic = (NSDictionary *) objTmp ;
            NSString * statusCode = [objDic objectForKey:@"statusCode"] ;
            if ([statusCode isEqualToString:@"1"]) {
                NSArray * dataArr = [objDic objectForKey:@"data"];
                for (NSDictionary *dic in dataArr) {
                    NSLog(@"%@",dic);
                    NoticesMsgModel *noticeMsg = [NoticesMsgModel new];
                    [noticeMsg parseDictionary:dic] ;
                    [_noticeArr addObject:noticeMsg];
                   
                }
                [_tableView reloadData] ; //刷新table
            }else{
            
            }
        }
    }];
    
    [msgRequest setFailedBlock:^{
        
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
        if ([noticeMsg.type integerValue] == 1) {
             NSDictionary * msgDic =  noticeMsg.message ;
            if (msgDic) {
                NSString * tmpUrl = [[msgDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@",BASEURL_IP,tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@",_urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [userApplyCell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
                [userApplyCell setFriendRequestInfo:[msgDic objectForKey:@"msg"]] ;
            }
        }else if ([noticeMsg.type integerValue] == 2) {

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
