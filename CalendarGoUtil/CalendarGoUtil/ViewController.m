//
//  ViewController.m
//  CalendarGoUtil
//
//  Created by IF on 15/6/17.
//  Copyright (c) 2015年 IF. All rights reserved.
//
#define kScreen_Width [[UIScreen mainScreen] bounds].size.width
#define kScreen_Height [[UIScreen mainScreen] bounds].size.height

#import "ViewController.h"
#import "Go2TimeRowsView.h"
#import "Go2DayPlannerView.h"
#import "TestViewCellTableViewCell.h"

@interface ViewController ()<Go2DayPlannerViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * testTableView ;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
//    Go2DayPlannerView * go2View = [[Go2DayPlannerView alloc] initWithFrame:CGRectMake(0, 60, kScreen_Width, kScreen_Height-60)] ;
//    go2View.delegate = self ;
//    [self.view addSubview:go2View] ;
    
    [self.view addSubview:self.testTableView];
}




-(UITableView *)testTableView{
    if (!_testTableView) {
        _testTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
        _testTableView.delegate = self ;
        _testTableView.dataSource = self ;
        _testTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
        [_testTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BG-Grey"]]];
    }
    return _testTableView ;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 106.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * textId = @"uitableviewcell" ;
    TestViewCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:textId];
    
    if (!cell) {
        cell  = (TestViewCellTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"TestViewCellTableViewCell" owner:self options:nil] firstObject];
    }
    
    return cell;
    
}


-(void)go2DayPlannerView:(Go2DayPlannerView *) plannerView didSelectDateDic:(NSDictionary *) didSelectDic{
    
}

-(void)deleteSelectDateDic:(NSDictionary *) willDeleteDateDic {
    
}

@end
