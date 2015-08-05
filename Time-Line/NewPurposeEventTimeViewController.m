//
//  NewPurposeEventTimeViewController.m
//  Go2
//
//  Created by IF on 15/6/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "NewPurposeEventTimeViewController.h"
#import "Go2DayPlannerView.h"
#import "ReviewViewController.h"
@interface NewPurposeEventTimeViewController ()<Go2DayPlannerViewDelegate>

@property (nonatomic,retain) NSMutableArray * voteTimeArr ;

@end

@implementation NewPurposeEventTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Purpose Event Time" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_right"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;

    
    Go2DayPlannerView * go2View = [[Go2DayPlannerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-60)] ;
    go2View.backgroundColor = [UIColor whiteColor] ;
    go2View.delegate = self ;
    [go2View showEventView:self.activeEvent.time];
    [self.view addSubview:go2View] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSMutableArray *)voteTimeArr{
    if (!_voteTimeArr) {
        _voteTimeArr = [NSMutableArray array];
    }
    return _voteTimeArr ;
}


-(void)go2DayPlannerView:(Go2DayPlannerView *) plannerView didSelectDateDic:(NSDictionary *) didSelectDic{
    [self.voteTimeArr addObject:didSelectDic] ;
}

-(void)deleteSelectDateDic:(NSDictionary *) willDeleteDateDic {
    [self.voteTimeArr removeObject:willDeleteDateDic];
}


-(void)backToEventDeatailsView:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{//
            [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 2:{//open ---> viewController
            if (self.voteTimeArr.count< 2 ) {
                [MBProgressHUD showError:@"Suggest two or more so that your friends can choose from"] ;
                return ;
            }
            self.activeDataMode.activeVoteDate = self.voteTimeArr ;
            ReviewViewController * reviewVC = [[ReviewViewController alloc] init] ;
            reviewVC.activeDataMode = self.activeDataMode ;
            if (self.isEdit) {
                reviewVC.isEdit = self.isEdit ;
                reviewVC.activeEvent = self.activeEvent ;
            }
            [self.navigationController pushViewController:reviewVC animated:YES] ;
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
    
}



@end
