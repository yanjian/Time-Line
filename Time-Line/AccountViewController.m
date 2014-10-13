//
//  AccountViewController.m
//  Time-Line
//
//  Created by IF on 14-10-13.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) UITableView *tableView;
@end

@implementation AccountViewController

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
    
    self.tableView=[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Disconnect";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    
    self.navigationItem.hidesBackButton=YES;
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftBtn.frame=CGRectMake(0, 0, 20, 20);
    [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.accountArr.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"INFO";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"cellDisconnect";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text=self.accountArr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) visibleCaTobackSetingView{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
