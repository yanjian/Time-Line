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
@interface ViewController ()<Go2DayPlannerViewDelegate>

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    Go2DayPlannerView * go2View = [[Go2DayPlannerView alloc] initWithFrame:CGRectMake(0, 60, kScreen_Width, kScreen_Height-60)] ;
    go2View.delegate = self ;
    [self.view addSubview:go2View] ;
}


-(void)go2DayPlannerView:(Go2DayPlannerView *) plannerView didSelectDateDic:(NSDictionary *) didSelectDic{
    
}

-(void)deleteSelectDateDic:(NSDictionary *) willDeleteDateDic {
    
}

@end
