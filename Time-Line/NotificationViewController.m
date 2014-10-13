//
//  NotificationViewController.m
//  Time-Line
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NotificationViewController.h"
#import "GoogleCalendarData.h"
#import "LocalCalendarData.h"

@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic,assign) BOOL isSelect;
@end

@implementation NotificationViewController


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
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.selectIndexPathArr=[NSMutableArray arrayWithCapacity:0];
    
    self.tableView=[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Notifications";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    
    self.navigationItem.hidesBackButton=YES;
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftBtn.frame=CGRectMake(0, 0, 20, 20);
    [leftBtn addTarget:self action:@selector(notificationTobackSetingView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.calendarArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr=self.calendarArray[section];
    return arr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *arr=self.calendarArray[section];
    GoogleCalendarData *tmpData= (GoogleCalendarData *)arr[0];
    return tmpData.Id;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"cellNotification";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *calendarListArr=[self.calendarArray objectAtIndex:indexPath.section];
    if (!self.isSelect) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectIndexPathArr addObject:indexPath];
        if (indexPath.section==self.calendarArray.count-1) {
            if(indexPath.row==calendarListArr.count-1){
                self.isSelect=YES;
            }
        }
    }
    id tmpObj=[calendarListArr objectAtIndex:indexPath.row];
    if ([tmpObj isKindOfClass:[GoogleCalendarData class]]) {
        GoogleCalendarData *data=(GoogleCalendarData*)tmpObj;
        cell.textLabel.text=data.summary;
    }else if([tmpObj isKindOfClass:[LocalCalendarData class]]){
        LocalCalendarData *data=(LocalCalendarData*)tmpObj;
        cell.textLabel.text=data.calendarName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType==UITableViewCellAccessoryCheckmark) {
        cell.accessoryType=UITableViewCellAccessoryNone;
        [self.selectIndexPathArr removeObject:indexPath];
    }else{
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectIndexPathArr addObject:indexPath];
    }
}

-(void) notificationTobackSetingView{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
