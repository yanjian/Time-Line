//
//  NoticeAndFriendAndManageViewController.m
//  Go2
//
//  Created by IF on 14/12/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticeAndFriendAndManageViewController.h"
#import "SegmentedControl.h"
#import "NoticesViewController.h"
#import "ManageViewController.h"
#import "FriendInfoViewController.h"
#import "SetingViewController.h"
#import "SloppySwiper.h"
#import "JCMSegmentPageController.h"


@interface NoticeAndFriendAndManageViewController ()<JCMSegmentPageControllerDelegate>{
    UIButton *_ZVbutton;//滑动试图左边view上的左边按钮
    UIButton *_rbutton;
}

@property (strong, nonatomic) SloppySwiper *swiper;

@end

@implementation NoticeAndFriendAndManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //主页面
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    rview.backgroundColor = defineBlueColor;

    // 导航
    UIView *zview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    zview.backgroundColor = defineBlueColor;
    
    // 右边xiew上返回button
    _rbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _rbutton.frame = CGRectMake(280, 30, 21, 25);
    [_rbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow1"] forState:UIControlStateNormal];
    [_rbutton addTarget:self action:@selector(setrbutton) forControlEvents:UIControlEventTouchUpInside];
    
    //左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(0, 20, 45, 45);
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"setting_default"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(setZVbutton) forControlEvents:UIControlEventTouchUpInside];
    [zview addSubview:_ZVbutton];
    [zview addSubview:_rbutton];
   
    [rview addSubview:zview];
    
    [self.view addSubview:rview];
    
    NoticesViewController *notivesView = [[NoticesViewController alloc] init];//初始化通知视图控制器

    
    ManageViewController *manageView = [[ManageViewController alloc] init];//初始化管理控制器

    
    FriendInfoViewController *friendView = [[FriendInfoViewController  alloc] init];
  
    
    NSArray *viewsControllers= @[notivesView, manageView,friendView];
    JCMSegmentPageController *segmentPageController = [[JCMSegmentPageController alloc] init];
    
    segmentPageController.delegate = self;
    segmentPageController.viewControllers = viewsControllers;
  
    
}



- (BOOL)segmentPageController:(JCMSegmentPageController *)segmentPageController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    NSLog(@"segmentPageController %@ shouldSelectViewController %@ at index %lu", segmentPageController, viewController, (unsigned long)index);
    return YES;
}

- (void)segmentPageController:(JCMSegmentPageController *)segmentPageController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    NSLog(@"segmentPageController %@ didSelectViewController %@ at index %lu", segmentPageController, viewController, (unsigned long)index);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 条到设置视图页面
-(void)setZVbutton
{
    /**另外一种导航滑动样式！
     SetingViewController *setVC=[[SetingViewController alloc] init];
     SetingsNavigationController *nc=[[SetingsNavigationController alloc] initWithRootViewController:setVC];
     nc.navigationBar.translucent=NO;
     nc.navigationBar.barTintColor=defineBlueColor;
     [self presentViewController:nc animated:YES completion:nil];
     self.isRefreshUIData=NO;
     */
    
    
    SetingViewController *setVC=[[SetingViewController alloc] init];
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:setVC];
    nc.navigationBar.translucent=NO;
    nc.navigationItem.hidesBackButton=YES;
    nc.navigationBar.barTintColor=defineBlueColor;
    self.swiper = [[SloppySwiper alloc] initWithNavigationController:nc];
    nc.delegate = self.swiper;
    [self presentViewController:nc animated:NO completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
