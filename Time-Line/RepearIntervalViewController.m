//
//  RepearIntervalViewController.m
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#define day  @"Daily"
#define week  @"Weekly"
#define year  @"Yearly"
#define month  @"Monthly"

#import "RepearIntervalViewController.h"

@interface RepearIntervalViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *dateDataArr;
}
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation RepearIntervalViewController

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
    if ([day isEqualToString:self.repeatParam] ) {
        dateDataArr=[NSArray arrayWithObjects:@"1 day",@"2 days",@"3 days",@"4 days",@"5 days",@"6 days",@"7 days",@"8 days",@"9 days",@"10 days", nil];
    }else if([year isEqualToString:self.repeatParam]){
         dateDataArr=[NSArray arrayWithObjects:@"1 year",@"2 years",@"3 years",@"4 years",@"5 years",@"6 years",@"7 years",@"8 years",@"9 years",@"10 years", nil];
    }else if([week isEqualToString:self.repeatParam]){
         dateDataArr=[NSArray arrayWithObjects:@"1 week",@"2 weeks",@"3 weeks",@"4 weeks",@"5 weeks",@"6 weeks",@"7 weeks",@"8 weeks",@"9 weeks",@"10 weeks", nil];
    }else if([month isEqualToString:self.repeatParam]){
         dateDataArr=[NSArray arrayWithObjects:@"1 month",@"2 months",@"3 months",@"4 months",@"5 months",@"6 months",@"7 months",@"8 months",@"9 months",@"10 months", nil];
    }
    
   //
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    titlelabel.text = @"Repeat";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-naviHigth) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dateDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString *cellID=@"repeatIntervalID";
    UITableViewCell *repeartCell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!repeartCell) {
        repeartCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    repeartCell.textLabel.text=dateDataArr[indexPath.row];
    return repeartCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate selectValueWithInterval:dateDataArr[indexPath.row]];
    [self disviewcontroller];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
