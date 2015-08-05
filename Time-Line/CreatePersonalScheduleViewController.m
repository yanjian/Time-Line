//
//  CreatePersonalScheduleViewController.m
//  Go2
//
//  Created by IF on 15/8/3.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "CreatePersonalScheduleViewController.h"

@interface CreatePersonalScheduleViewController ()

@property (nonatomic,retain) UIView   * navView ;
@property (nonatomic,retain) UIView   * scheduleView;
@property (nonatomic,retain) UIView   * personalView;

@property (nonatomic,retain) UIControl  *  cancelView;

@property (nonatomic,retain) UIButton * scheduleBtn ;

@property (nonatomic,retain) UIButton * personalBtn ;
@end

@implementation CreatePersonalScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    
    [self.view addSubview:self.navView]      ;
    [self.view addSubview:self.scheduleView] ;
    [self.view addSubview:self.personalView] ;
    [self.view addSubview:self.cancelView]   ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}


-(UIView *)navView {
    if (!_navView) {
        _navView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
        UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)] ;
        titleLab.text = @"Create an Event" ;
        [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        titleLab.textAlignment = NSTextAlignmentCenter ;
        titleLab.textColor = RGB(39, 135, 237);
        [_navView addSubview:titleLab];
    }
    return _navView;
}



-(UIView *)scheduleView{
    if (!_scheduleView) {
    
        _scheduleView = [[UIControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navView.bounds), kScreen_Width, (kScreen_Height-110)/2)] ;
        self.scheduleBtn.frame  = CGRectMake(0, 0, 100, 100) ;
        self.scheduleBtn.center = CGPointMake(_scheduleView.frame.size.width/2, _scheduleView.frame.size.height/3) ;
        
        UILabel * scheduleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scheduleBtn.frame), kScreen_Width, _scheduleView.frame.size.height/4)] ;
        [scheduleLab setText:@"Schedule with friends"];
        [scheduleLab setTextColor: RGB(39, 135, 237)] ;
        [scheduleLab setTextAlignment:NSTextAlignmentCenter] ;
        [_scheduleView addSubview:self.scheduleBtn];
        [_scheduleView addSubview:scheduleLab];
    }
    return _scheduleView ;
}


-(UIView *)personalView{
    if (!_personalView) {
        
        _personalView = [[UIControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scheduleView.frame), kScreen_Width, (kScreen_Height-110)/2)] ;
        self.personalBtn.frame  = CGRectMake(0, 0, 100, 100) ;
        self.personalBtn.center = CGPointMake(_personalView.frame.size.width/2, _personalView.frame.size.height/3) ;
        
        UILabel * personalLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.personalBtn.frame), kScreen_Width, self.personalView.frame.size.height/4)] ;
        [personalLab setText:@"Personal"];
        [personalLab setTextColor: RGB(39, 135, 237)] ;
        [personalLab setTextAlignment:  NSTextAlignmentCenter] ;
        
        [_personalView addSubview:self.personalBtn];
        [_personalView addSubview:personalLab];
    }
    
    return _personalView ;
}


-(UIButton *)scheduleBtn {
    if (!_scheduleBtn) {
        _scheduleBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        _scheduleBtn.frame = CGRectZero ;
        _scheduleBtn.tag = 0 ;
        [_scheduleBtn setBackgroundImage:[UIImage imageNamed:@"Schedule"] forState:UIControlStateNormal] ;
        [_scheduleBtn addTarget:self action:@selector(createScheduleFriends:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scheduleBtn ;
}


-(UIButton *)personalBtn {
    if (!_personalBtn) {
        _personalBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        _personalBtn.frame = CGRectZero;
         _scheduleBtn.tag = 1 ;
        [_personalBtn setBackgroundImage:[UIImage imageNamed:@"Personal"] forState:UIControlStateNormal] ;
        [_personalBtn addTarget:self action:@selector(createScheduleFriends:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _personalBtn ;
}

-(UIControl *)cancelView{
    if (!_cancelView) {
         _cancelView = [[UIControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.personalView.frame)-20, kScreen_Width, 64)] ;
        
        UILabel * personalLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_cancelView.frame), CGRectGetHeight(_cancelView.frame))] ;
        
        [personalLab setText:@"Cancel"];
        [personalLab setTextColor: [UIColor grayColor]] ;
        [personalLab setTextAlignment:  NSTextAlignmentCenter] ;
        [_cancelView addTarget:self action:@selector(cancelCreateEvent) forControlEvents:UIControlEventTouchUpInside];
        [_cancelView addSubview:personalLab];
    }
    return _cancelView ;
}

-(void)createScheduleFriends:(UIButton *) sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(createPersonalScheduleViewControllerDelegate:buttonTag:)]) {
        [self.delegate createPersonalScheduleViewControllerDelegate:self buttonTag:sender.tag];
    }
}

-(void)cancelCreateEvent{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL)prefersStatusBarHidden{
    return YES ;
}

@end
