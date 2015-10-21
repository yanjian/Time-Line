//
//  NewPurposeEventTimeViewController.m
//  Go2
//
//  Created by IF on 15/6/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "NewPurposeEventTimeViewController.h"
#import "Go2DayPlannerView.h"
//#import "ReviewViewController.h"

#import "InviteesViewController.h"

@interface NewPurposeEventTimeViewController ()<Go2DayPlannerViewDelegate>{
    NSMutableArray * selectFriendArr ;
}

@property (nonatomic,strong) UIButton *leftBtn ;
@property (nonatomic,strong) UIButton *rightBtn ;
@property (nonatomic,strong) Go2DayPlannerView * go2View;

@property (nonatomic,retain) NSMutableArray * voteTimeArr ;

@end

@implementation NewPurposeEventTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectFriendArr = @[].mutableCopy ;
    
    self.title = @"Purpose Event Time" ;
    [self.leftBtn setTag:1];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    
    [self.rightBtn setTag:2];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    
    [self.view addSubview:self.go2View] ;
}

-(UIButton *)leftBtn{
    if (!_leftBtn) {
         _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
        [_leftBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _leftBtn ;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_right"] forState:UIControlStateNormal] ;
        [_rightBtn addTarget:self action:@selector(backToEventDeatailsView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _rightBtn ;
}

-(Go2DayPlannerView *)go2View{
    if (!_go2View) {
        _go2View= [[Go2DayPlannerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-60)] ;
        _go2View.backgroundColor = [UIColor whiteColor] ;
        _go2View.delegate = self ;
        [_go2View showEventView:self.activeEvent.proposeTimes];
    }
    return _go2View;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
            InviteesViewController * inviteesVC = [[InviteesViewController alloc] init] ;
            inviteesVC.activeDataMode = self.activeDataMode ;
            inviteesVC.navStyleType = NavStyleType_LeftRightSame ;
            
            if (self.isEdit) {
                [selectFriendArr removeAllObjects];
                for (NSDictionary *tmpDic in self.activeEvent.invitees) {
                    [selectFriendArr addObject:[tmpDic objectForKey:@"uid"]];
                }
                inviteesVC.joinAllArr = selectFriendArr ;
                inviteesVC.isEdit = self.isEdit ;
                inviteesVC.activeEvent = self.activeEvent ;
            }
            [self.navigationController pushViewController:inviteesVC animated:YES] ;
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
    
}



@end
