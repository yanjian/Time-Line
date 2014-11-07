//
//  SetingViewController.m
//  Time-Line
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "SetingViewController.h"
#import "VisibleCalendarsViewController.h"
#import "NotificationViewController.h"
#import "PreferenceViewController.h"
#import "GoogleCalendarData.h"
#import "GoogleLoginViewController.h"
#import "AccountViewController.h"
#import "IBActionSheet.h"
#import "LoginViewController.h"
#import "LocalCalendarData.h"
#import "AT_Account.h"

@interface SetingViewController ()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,IBActionSheetDelegate>{
    BOOL isUserInfo;
    BOOL isLogout;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *dataArr;
@property (nonatomic,retain) NSMutableArray *titleHeadArr;
@property (nonatomic,retain) NSMutableArray *settingDataArr;
@property (nonatomic,retain) NSMutableArray *moreDataArr;

@property (nonatomic,retain) NSMutableArray *calendarArray;

@property (nonatomic,retain) NSMutableArray *calendarListArr;
@end

@implementation SetingViewController
@synthesize settingDataArr,accountDataArr,moreDataArr,dataArr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    dataArr=[NSMutableArray arrayWithCapacity:0];
    accountDataArr =  [NSMutableArray arrayWithCapacity:0];
    self.calendarArray=[NSMutableArray arrayWithCapacity:0];
    
    self.titleHeadArr = [[NSMutableArray alloc] initWithObjects:@"SETTINGS",@"ACCOUNTS",@"MORE", nil];
    
    settingDataArr =  [[NSMutableArray alloc] initWithObjects:@"Visible Calendars",@"Notifications",@"Preference", nil];
    moreDataArr    =  [[NSMutableArray alloc] initWithObjects:@"Support",@"Rate in App Store",@"Logout", nil];
    self.tableView =  [[UITableView alloc]initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    
    [dataArr addObject:settingDataArr];
    [dataArr addObject:accountDataArr];
    [dataArr addObject:moreDataArr];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame=CGRectMake(0, 0, 20, 20);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Cross"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(closeNavigation) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Setings";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [accountDataArr removeAllObjects];

    self.calendarListArr=[[AT_Account MR_findAll] mutableCopy];//[g_AppDelegate loadDataFromFile:calendarList];
   // if (g_NetStatus==NotReachable) {
        if (self.calendarListArr) {
            for (AT_Account *atAccount in self.calendarListArr) {
                [accountDataArr addObject:atAccount];
             }
            [accountDataArr addObject:@"Add Account"];
            [self.tableView reloadData];
        }
   // }
//    ASIHTTPRequest *request=[t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
//    [request startAsynchronous];
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{

    return  self.titleHeadArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr=[dataArr objectAtIndex:section];
    if (arr) {
        return arr.count;
    }else{
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.titleHeadArr[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier=@"SetingId";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.tag=[[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,indexPath.row ] intValue];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
  
    NSArray *viewarr=[cell.contentView subviews];
    for (UIView *view in viewarr) {
        [view removeFromSuperview];
    }
    
    NSArray *arr=[dataArr objectAtIndex:indexPath.section];
    id tmpObj=arr[indexPath.row];
    if ([tmpObj isKindOfClass:[NSString class]]) {
        cell.textLabel.text=tmpObj;
    }else if([tmpObj isKindOfClass:[AT_Account class]]){
        AT_Account *atAccount=(AT_Account *)tmpObj;
        UILabel *lab=[self createUILabe];
        UILabel *contextLab=[[UILabel alloc] initWithFrame:CGRectMake(lab.bounds.size.width, 2, 215, 40)];
        contextLab.lineBreakMode=NSLineBreakByTruncatingTail;
        [contextLab setBackgroundColor:[UIColor clearColor]];
        if ([atAccount.accountType intValue]==AccountTypeGoogle) {
            lab.text=@"G";
           [contextLab setText:atAccount.account];
        }else if([atAccount.accountType intValue]==AccountTypeLocal){
           lab.text=@"IF";
           [contextLab setText:atAccount.account];
        }
        [cell.contentView addSubview:lab];
        [cell.contentView addSubview:contextLab];
    }
    return cell;
}


-(UILabel *) createUILabe{
    UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setFont:[UIFont fontWithName:@"Verdana-Bold" size:17.f]];
    return lab;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectCell=[tableView cellForRowAtIndexPath:indexPath];
    if (selectCell.tag==0) {
        VisibleCalendarsViewController *vc=[[VisibleCalendarsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES ];
    }else if (selectCell.tag==1){
        NotificationViewController *notificationVC=[[NotificationViewController alloc] init];
        [self.navigationController pushViewController:notificationVC animated:YES];
    }else if (selectCell.tag==2){
        PreferenceViewController *preferenceVC=[[PreferenceViewController alloc] init];
        [self.navigationController pushViewController:preferenceVC animated:YES];
    }else if(selectCell.tag==20){
    
    }else if(selectCell.tag==21){
        
    }else if(selectCell.tag==22){
        IBActionSheet *ibActionSheet=[[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil, nil];
        [ibActionSheet showInView:self.navigationController.view];
    }else {
        id rowData=[[dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([rowData isKindOfClass:[NSString class]]) {
            if ([@"Add Account" isEqualToString:rowData]) {
                GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
                glvc.isBind=YES;
                glvc.isSeting=YES;
                [self.navigationController pushViewController:glvc animated:YES];
            }
        }else if ([rowData isKindOfClass:[AT_Account class]]){
            AccountViewController *accountVC=[[AccountViewController alloc] init];
            accountVC.accountArr=[NSMutableArray arrayWithObjects:rowData, nil];
            [self.navigationController pushViewController:accountVC animated:YES];
        }
    }
}


//ibactionsheet的代理
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        isLogout=YES;
        ASIHTTPRequest *request =  [t_Network httpGet:nil Url:account_Logoff Delegate:self Tag:account_Logoff_Tag];
        [request startAsynchronous];
        NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
        
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"account==%@",[userInfo objectForKey:@"email"]];
        NSArray  *atAccountArr=[AT_Account MR_findAllWithPredicate:pre];
        
        for(AT_Account *atAccount in atAccountArr){
            [atAccount MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        [userInfo removeObjectForKey:@"userName"];
        [userInfo removeObjectForKey:@"loginStatus"];
        [userInfo removeObjectForKey:@"accountBinds"];
        [userInfo removeObjectForKey:@"email"];
        [userInfo removeObjectForKey:@"authCode"];
        [userInfo removeObjectForKey:@"pwd"];
        [userInfo removeObjectForKey:@"accountType"];
        [userInfo synchronize];
    
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        [self presentViewController:loginVc animated:YES completion:nil];
        [self closeNavigation];
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request{

    NSString *dataStr= [request responseString];
    if (!isLogout) {
        id objId= [dataStr objectFromJSONString];
        //{"statusCode":"1","message":"成功","data":[{"account":"yanjaya5201314@gmail.com","type":"1","uid":"74"}]}
        if ([objId isKindOfClass:[NSDictionary class]]) {
            NSDictionary *Datadic=(NSDictionary *)objId;
            NSString *statusCode=[Datadic objectForKey:@"statusCode"];
            if ([@"1" isEqualToString:statusCode]) {
                if (!isUserInfo) {
                    [accountDataArr removeAllObjects];
                    NSDictionary *userInfoDic=[Datadic objectForKey:@"data"];
                    [accountDataArr addObject:[userInfoDic objectForKey:@"email"]];
                    ASIHTTPRequest *request=[t_Network httpGet:nil Url:get_AccountBindList Delegate:self Tag:get_AccountBindList_Tag];
                    [request startAsynchronous];
                    isUserInfo=YES;
                }else{
                    NSArray *bindArr=[Datadic objectForKey:@"data"];
                    for (NSDictionary *dataDic in bindArr) {
                        [accountDataArr addObject:[dataDic objectForKey:@"account"]];
                    }
                    isUserInfo=NO;
                    [self.accountDataArr addObject:@"Add Account"];
                    [self.tableView reloadData];
                }
            }

        }else{
            if ([@"1" isEqualToString:dataStr]) {
                
            }
            isLogout=NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) closeNavigation{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
