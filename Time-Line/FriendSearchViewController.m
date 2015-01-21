//
//  FriendSearchViewController.m
//  Time-Line
//
//  Created by IF on 14/12/9.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendInfoTableViewCell.h"
#import "Friend.h"
#import "UIImageView+WebCache.h"
#import "LPPopupListView.h"
@interface FriendSearchViewController ()<UITableViewDelegate,UITableViewDataSource,LPPopupListViewDelegate>{
    NSMutableArray *searchFriendArr;
    NSIndexPath *selectIndexPath;//用户选择的行数
   
}
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame=CGRectMake(0, 44, kScreen_Width, kScreen_Height);
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    navBar.translucent=NO;
    navBar.barTintColor=blueColor;
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:nil];
    //创建一个左边按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(20, 30, 21, 25)];
    [leftBtn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    navItem.leftBarButtonItem=leftButton;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =@"Add Friend";
    navItem.titleView =titleLabel;
    
    [navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:navBar];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64+5, kScreen_Width, kScreen_Height-naviHigth) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView] ;
}


#pragma mark -创建搜索视图
-(UIView *)createTableHead{
    
    UIView * headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    CGRect  rect=CGRectMake(20, 0, 200, 30);
    self.searchText = [[UITextField alloc] initWithFrame:rect];
    self.searchText.borderStyle=UITextBorderStyleLine;
    [headView addSubview:self.searchText];
    
    self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    self.searchBtn.frame = CGRectMake( rect.size.width+rect.origin.x+10, 0, 70, 30);
    [self.searchBtn setBackgroundColor:purple];
    [self.searchBtn addTarget:self action:@selector(searchFriendAdd:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:self.searchBtn];
    [headView setBackgroundColor:[UIColor whiteColor]];
    return headView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onClickClose{
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchFriendAdd:(UIButton *)sender {
    searchFriendArr = [NSMutableArray array];
   
    if (self.searchText.text && ![self.searchText.text isEqualToString:@""]) {
         [MBProgressHUD showMessage:@"Search..."];
        ASIHTTPRequest *request = [t_Network httpGet:@{@"uid":self.searchText.text}.mutableCopy Url:anyTime_FindUser Delegate:nil Tag:anyTime_FindUser_tag];
        __block ASIHTTPRequest *searchRequest = request ;
        [request setCompletionBlock:^{
            NSString *responseStr = [searchRequest responseString];
            NSLog(@"%@", responseStr);
            NSDictionary *tmpObj = [responseStr objectFromJSONString];
            NSString  *statusCode= [tmpObj objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                id friendObj= [tmpObj objectForKey:@"data"];
                if ([friendObj isKindOfClass:[NSArray class]]) {
                    NSArray *friendArr =(NSArray *)friendObj;
                    for (NSDictionary * dic in friendArr) {
                        NSString * nickName = [dic objectForKeyedSubscript:@"nickName"];
                        NSMutableDictionary *ndic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [ndic removeObjectForKey:@"nickName"];
                        if(nickName)
                           [ndic setObject:nickName forKey:@"nickname"];
                        Friend * friend = [Friend friendWithDict:ndic];
                        friend.imgBig=[friend.imgBig stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                        friend.imgSmall=[friend.imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                        [searchFriendArr addObject:friend];
                    }
                }
            }
            [MBProgressHUD hideHUD];
        }];
        [request setFailedBlock:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"Network error!"];
        }];
        [request startSynchronous];
        [self.tableView reloadData];
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchFriendArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [self createTableHead];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellFriendId";

    FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = (FriendInfoTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
    }

    Friend *friend = searchFriendArr[indexPath.row];
    
    
    NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,friend.imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",_urlStr);
    NSURL *url=[NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
    //cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    cell.nickName.text = friend.nickname;
    cell.userNote.text = friend.alias;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectIndexPath = indexPath;
    LPPopupListView *lpopView = [[LPPopupListView alloc] initWithTitle:@"Select Group" list:nil selectedIndexes:nil point:CGPointMake(20, 70) size:CGSizeMake(kScreen_Width-40, kScreen_Height-100) multipleSelection:NO];
    lpopView.titleLabel.textAlignment = NSTextAlignmentCenter;
    lpopView.delegate = self;
    [lpopView showInView:self.view animated:YES];
}

#pragma mark -LPPopupListView的代理
- (void)popupListView:(LPPopupListView *)popupListView didSelectFriendGroup:(FriendGroup *) selectFriendGroup{
    Friend *friend = searchFriendArr[selectIndexPath.row];
    ASIHTTPRequest *addFriendRequest = [t_Network httpPostValue:@{@"fid":friend.Id,@"tid":selectFriendGroup.Id,@"name":friend.username}.mutableCopy Url:anyTime_AddFriend Delegate:nil Tag:anyTime_AddFriend_tag];
    __block ASIHTTPRequest *friendRequest = addFriendRequest ;
    [addFriendRequest setCompletionBlock:^{
        NSString *responseStr = [friendRequest responseString];
        NSLog(@"%@",responseStr);
        id  objTmp = [responseStr objectFromJSONString];
        NSString *statusCode = [objTmp objectForKey:@"statusCode"];
        if ([statusCode isEqualToString:@"1"]) {
            [MBProgressHUD showSuccess:@"Friend request sent. Please wait for confirmation"];
        }else{
             [MBProgressHUD showError:@"Fail to send friend request"];
        }
    }];
    [addFriendRequest setFailedBlock:^{
       [MBProgressHUD showError:@"Fail to send friend request"];
    }];
    [addFriendRequest startAsynchronous];
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
