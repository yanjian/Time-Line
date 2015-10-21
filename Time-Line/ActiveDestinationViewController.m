//
//  ActiveDestinationViewController.m
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveDestinationViewController.h"
#import "ActiveInfoTableViewController.h"
#import "ActiveVotingViewController.h"
#import "ChatViewController.h"
#import "ActiveAlbumsViewController.h"
#import "ActiveEventMode.h"
#import "ActiveSetingTableViewController.h"
#import "TimeVoteModel.h"
#import "ManageViewController.h"
#import "Go2ChildTableViewController.h"

@interface ActiveDestinationViewController ()<ASIHTTPRequestDelegate,ActiveSetingTableViewControllerDelegate>
{
    ActiveInfoTableViewController * activeInfoVc ;
    ActiveVotingViewController * activeVotingVc ;
    Go2ChildTableViewController *chatVc;
    ActiveAlbumsViewController * activeAlbumsVc ;
}

@property (nonatomic,strong)   UIButton *leftBtn ;
@property (nonatomic,strong)   UIButton *rightBtn ;

@end

@implementation ActiveDestinationViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self ;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event";
    [self.buttonBarView.selectedBar setBackgroundColor:[UIColor orangeColor]];
    
    self.containerView.bounces = NO ; //XLButtonBarPagerTabStripViewController中的属性
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
 //   [self colorWithNavigationBar];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.manageViewController fefreshTableView] ;
}

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{

//    activeInfoVc  = [[ActiveInfoTableViewController alloc]   init];
//    activeInfoVc.activeEvent = self.activeEventInfo ;
//    activeInfoVc.activeDestinationBlank = ^(){
//        [pagerTabStripViewController moveToViewControllerAtIndex:1];//这里
//    };
    
//    activeVotingVc   = [[ActiveVotingViewController alloc] init];
//    activeVotingVc.activeEvent = self.activeEventInfo ;
//
//    chatVc = [[Go2ChildTableViewController alloc] init] ;
//    chatVc.activeEvent = self.activeEventInfo ;

    activeAlbumsVc   = [[ActiveAlbumsViewController alloc] init];
    activeAlbumsVc.eid =  self.activeEventInfo.Id ;
    return @[activeInfoVc,activeVotingVc,chatVc,activeAlbumsVc];
}


/**
 *配置NavigationBar的颜色，和字体的颜色
 */
-(void)colorWithNavigationBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)backToEventView:(UIButton *) sender{
    switch (sender.tag) {
        case 1:{
               [self.navigationController popViewControllerAnimated:YES] ;
            }break;
        case 2:{
                ActiveSetingTableViewController * activeSetingVC = [[ActiveSetingTableViewController alloc] init];
                activeSetingVC.activeEvent = self.activeEventInfo ;
                activeSetingVC.delegate = self ;
            
                [self.navigationController pushViewController:activeSetingVC animated:YES];
            }break;
        default:
            break;
    }
}

-(void)activeSetingTableViewControllerDelegate:(ActiveSetingTableViewController *) activeViewController isChange:(BOOL) isChange{
    if(isChange){
        [activeInfoVc refreshActiveEventData:self.activeEventInfo.Id];
         self.activeEventInfo = activeInfoVc.activeEvent;
    }
}




//----------------------------- get method --------------------------------------

-(UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [_leftBtn setTag:1];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
        [_leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
        
    }
    return _leftBtn ;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:CGRectMake(0, 0, 22, 17)];
        [_rightBtn setTag:2];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Menu"] forState:UIControlStateNormal] ;
        [_rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _rightBtn ;
}

@end
