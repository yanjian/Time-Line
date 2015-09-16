//
//  ManageAndScheduleParentViewController.m
//  Go2
//
//  Created by IF on 15/7/23.
//  Copyright (c) 2015年 zhilifang. All rights reserved.


#import "ManageAndScheduleParentViewController.h"
#import "ManageViewController.h"
#import "HomeViewController.h"
#import "AddNewActiveViewController.h"
#import "SimpleEventViewController.h"

#import "CreatePersonalScheduleViewController.h"

@interface ManageAndScheduleParentViewController ()<UIActionSheetDelegate,CreatePersonalScheduleViewControllerDelegate,SimpleEventViewControllerDelegate>

@property (nonatomic,retain) UIViewController * currentViewController ;
@property (nonatomic,retain) UIButton * createBtn ;

@property (nonatomic,retain) UIButton * swichMonthBtn ;
@property (nonatomic,retain) UIImageView * iconImgView ;
@end

@implementation ManageAndScheduleParentViewController
@synthesize currentViewController ;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Event" ;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:self.swichMonthBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.createBtn];
    
    ManageViewController * manageVC = [[ManageViewController alloc] init];
    [self addChildViewController:manageVC] ;
    
    HomeViewController * homeVC = [[HomeViewController alloc] init];
    [self addChildViewController:homeVC] ;
    
    [self.view  addSubview:manageVC.view] ;
    currentViewController = manageVC ;
}


-(UIButton *)createBtn{
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createBtn setFrame:CGRectMake(0, 0, 20 , 20)];
        [_createBtn setTag:1];
        [_createBtn setBackgroundImage:[UIImage imageNamed:@"Friends_Normal"] forState:UIControlStateNormal] ;
        [_createBtn addTarget:self action:@selector(createNewActive) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _createBtn ;
}

-(UIButton *)swichMonthBtn{
    if (!_swichMonthBtn) {
        _swichMonthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swichMonthBtn setFrame:CGRectMake(0, 0, 23 , 20)];
        [_swichMonthBtn setTag:1];
        [_swichMonthBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Menu"] forState:UIControlStateNormal] ;
        [_swichMonthBtn addTarget:self action:@selector(searchNewActive) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _swichMonthBtn ;
}

-(UIImageView *)iconImgView{
    if (!_iconImgView) {
        self.iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_icon"]];
        self.iconImgView.frame = CGRectMake(0, 0, 10, 10);
    }
    return _iconImgView ;
}

-(void)searchNewActive{
    HomeViewController * homeVC   = [self.childViewControllers objectAtIndex:1];
    UIViewController   * oldViewController = currentViewController;
    if (currentViewController != homeVC) {
        [self transitionFromViewController:currentViewController toViewController:homeVC duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [UIView animateWithDuration:0.5 animations:^{
                self.swichMonthBtn.transform = CGAffineTransformMakeRotation(-(90.0f*M_PI)/180.f);
            } completion:^(BOOL finished) {}];
            
        }  completion:^(BOOL finished) {
            if (finished) {
                UIControl * titleControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                [titleControl setBackgroundColor:[UIColor clearColor]] ;
                UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                [titleLab setBackgroundColor:[UIColor clearColor]];
                [titleLab setTextAlignment:NSTextAlignmentCenter] ;
                [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
                titleLab.text = @"Schedule";
                [titleLab setTextColor:[UIColor whiteColor]];
                [titleControl addSubview:titleLab];
                
                self.iconImgView.center = CGPointMake(titleControl.bounds.size.width/2+50, titleControl.bounds.size.height/2);
                [titleControl addSubview:self.iconImgView];
                
                [titleControl addTarget:self action:@selector(blackToday) forControlEvents:UIControlEventTouchUpInside];
                self.navigationItem.titleView = titleControl;
                currentViewController = homeVC;
            }else{
                currentViewController = oldViewController;
            }
        }];
    }else{
        ManageViewController * manageVC = [self.childViewControllers objectAtIndex:0];
        [self transitionFromViewController:currentViewController toViewController:manageVC duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [UIView animateWithDuration:0.5 animations:^{
               self.swichMonthBtn.transform = CGAffineTransformMakeRotation(0);
            } completion:^(BOOL finished) {}];
        }  completion:^(BOOL finished) {
            if (finished) {
                self.title = @"Event" ;
                self.navigationItem.titleView = nil;
                currentViewController = manageVC;
            }else{
                currentViewController = oldViewController;
            }
        }];
    }
    
}


-(void)blackToday{
     HomeViewController   * homeVC   = [self.childViewControllers objectAtIndex:1];
    [homeVC oClickArrow:self.iconImgView];
}

-(void)createNewActive{
    
    CreatePersonalScheduleViewController *psVc = [[CreatePersonalScheduleViewController alloc] init];
    psVc.delegate = self ;
    [self presentViewController:psVc animated:YES completion:nil];
    
//    UIActionSheet *activeSheet = [[UIActionSheet alloc] initWithTitle:@"Add Event" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Social",@"Personal", nil];
//    [activeSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        AddNewActiveViewController * antVC  =[[AddNewActiveViewController alloc] init];
        antVC.hidesBottomBarWhenPushed = YES ;
        [self.navigationController  pushViewController:antVC animated:YES ] ;
    }else if (buttonIndex == 1){
        SimpleEventViewController * simpleEventVC = [[SimpleEventViewController alloc] init];
        simpleEventVC.hidesBottomBarWhenPushed = YES ;
        [self.navigationController pushViewController:simpleEventVC animated:YES];
    }
    
}


-(void)createPersonalScheduleViewControllerDelegate:(CreatePersonalScheduleViewController *)createPersonSchelduleVC buttonTag:(NSInteger) tag{
    [createPersonSchelduleVC dismissViewControllerAnimated:YES completion:nil];
    if (tag == 0) {
        AddNewActiveViewController * antVC  =[[AddNewActiveViewController alloc] init];
        antVC.hidesBottomBarWhenPushed = YES ;
        [self.navigationController  pushViewController:antVC animated:YES ] ;
    }else if (tag == 1){
        SimpleEventViewController * simpleEventVC = [[SimpleEventViewController alloc] init];
        simpleEventVC.hidesBottomBarWhenPushed = YES ;
         simpleEventVC.delegate = self ;
        [self.navigationController pushViewController:simpleEventVC animated:YES];
    }

}

-(void)dissSimpleEventViewController:(SimpleEventViewController *) simpleEventVC {

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
