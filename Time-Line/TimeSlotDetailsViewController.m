//
//  TimeSlotDetailsViewController.m
//  Go2
//
//  Created by IF on 15/4/17.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "TimeSlotDetailsViewController.h"
#import "VotedTableViewController.h"
#import "ScheduleViewController.h"

@interface TimeSlotDetailsViewController ()

@end

@implementation TimeSlotDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.title = @"Time SlotDetails";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    VotedTableViewController * voteVc = [[VotedTableViewController alloc] init];
    voteVc.voteMemberArr = self.voteMemberArr ;
    
    ScheduleViewController * sheduleVc = [[ScheduleViewController alloc] init];
    return @[voteVc/*,sheduleVc*/];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)backToEventView:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}
@end
