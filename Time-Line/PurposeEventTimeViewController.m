//
//  PurposeEventTimeViewController.m
//  Time-Line
//
//  Created by IF on 15/3/26.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "PurposeEventTimeViewController.h"
#import "AllDateViewController.h"
#import "BaseAnimation.h"
#import "ModalAnimation.h"
#import "DateVoteShowTableViewCell.h"
#import "ReviewViewController.h"

@interface PurposeEventTimeViewController ()<UIViewControllerTransitioningDelegate,AllDateViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
     ModalAnimation *_modalAnimationController;
     __block NSMutableArray * voteTimeArr ;
   
}
@property (nonatomic,retain) UILabel * placeholderLab ;
@end

@implementation PurposeEventTimeViewController
@synthesize dateShowTableView;
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
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;

    _modalAnimationController = [[ModalAnimation alloc] init];
    
    voteTimeArr = [NSMutableArray array];
    [self createPlaceholderLab];
    [self creatAddActiveTimeBtn];
    if (self.isEdit) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
        for (NSDictionary *tmpDic in self.activeEvent.time) {
            NSDate  * startDate = [dateFormatter dateFromString:[tmpDic objectForKey:@"startTime"]] ;
            NSDate  * endDate   = [dateFormatter dateFromString:[tmpDic objectForKey:@"endTime"]] ;
            [voteTimeArr addObject:@{startTime:startDate,endTime:endDate,@"id":[tmpDic objectForKey:@"id"]}];
        }
    }
}

-(void)createPlaceholderLab{
    NSString * placeStr = @"Purpose several possible time for the event for your friends to choose from.\n\nWe'll help you to find the best time for your awesome event that everyone can join!" ;
    
    self.placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.placeholderLab setNumberOfLines:0];
    self.placeholderLab.text = placeStr;
    self.placeholderLab.textColor = [UIColor grayColor];
    UIFont * tfont = [UIFont systemFontOfSize:19];
    self.placeholderLab.font = tfont ;
    self.placeholderLab.lineBreakMode =NSLineBreakByTruncatingTail ;
    
    [self.view addSubview:self.placeholderLab];
    
    // label可设置的最大高度和宽度
    CGSize size = CGSizeMake(300.f, MAXFLOAT);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[placeStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    self.placeholderLab.frame =CGRectMake(10,actualsize.width/2, kScreen_Width-20, actualsize.height);
    
    //self.placeholderLab.center = CGPointMake(, actualsize.height/2);
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)creatAddActiveTimeBtn{
    UIButton * addVoteTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addVoteTimeBtn.frame = CGRectMake(kScreen_Width-70, kScreen_Height-130, 50, 50);
    [addVoteTimeBtn setBackgroundImage:[UIImage imageNamed:@"add_default"] forState:UIControlStateNormal] ;
    addVoteTimeBtn.layer.masksToBounds = YES;
    addVoteTimeBtn.layer.cornerRadius = 25;
    [addVoteTimeBtn addTarget:self action:@selector(pushToDateView:) forControlEvents:UIControlEventTouchUpInside ];
    [self.view addSubview:addVoteTimeBtn];
}

-(void)pushToDateView:(UIButton *) sender {
    AllDateViewController * allDateVC = [[AllDateViewController alloc] initWithNibName:@"AllDateViewController" bundle:nil] ;
    allDateVC.modalPresentationStyle = UIModalPresentationCustom;
    allDateVC.transitioningDelegate = self;
    allDateVC.delegate = self ;
    [self presentViewController:allDateVC animated:YES completion:nil];
}

/**
 *AllDateViewController的delegate
 */
-(void)allDateViewController:(AllDateViewController *) allDateViewController dateDic:(NSDictionary *) dateDic {
    NSLog(@"start: %@  ---- end: %@",[dateDic objectForKey:startTime],[dateDic objectForKey:endTime]);
    [voteTimeArr addObject:dateDic];
    [dateShowTableView reloadData];
}


//-----tableview-----
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (voteTimeArr.count <= 0) {
    }else{
        [self.placeholderLab removeFromSuperview];
    }

    return voteTimeArr.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DateVoteShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"voteTimeCellID"];
    if (!cell) {
        cell = (DateVoteShowTableViewCell *)[[[UINib nibWithNibName:@"DateVoteShowTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    }
    NSDictionary * dataDic = [voteTimeArr objectAtIndex:indexPath.section];
    NSDate  * startDate = [dataDic objectForKey:startTime] ;
    NSDate  * endDate   = [dataDic objectForKey:endTime] ;
   
    cell.startTimeOrDay.text = [NSString stringWithFormat:@"From - %@",[self formaterDate:[dataDic objectForKey:startTime]]]   ;
    cell.timeOrEenTime.text  = [NSString stringWithFormat:@"  To - %@",[self formaterDate:[dataDic objectForKey:endTime]] ];
    cell.showTimeInterval.text = [NSString stringWithFormat:@"%i", [self intervalFromLastDate:endDate toTheDate:startDate]];
    
    UIButton * deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)];
    [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    deleteBtn.tag =indexPath.section ;
    [deleteBtn addTarget:self action:@selector(deleteActiveTime:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = deleteBtn ;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(void)deleteActiveTime:(UIButton *)sender {
    [voteTimeArr removeObjectAtIndex:sender.tag] ;
    [self.dateShowTableView deleteSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationTop];
    [self.dateShowTableView reloadData];

}
//--------


#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backToEventDeatailsView:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{//
            [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 2:{//open ---> viewController
            if (voteTimeArr.count< 2 || !voteTimeArr ) {
                [MBProgressHUD showError:@"Suggest two or more so that your friends can choose from"] ;
                return ;
            }
            self.activeDataMode.activeVoteDate = voteTimeArr ;
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

-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm EEE dd,MMM,yyyy "];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}


-(int)intervalFromLastDate: (NSDate *) date1  toTheDate:(NSDate *) date2{
    //得到相差秒数
    NSTimeInterval time=[date1 timeIntervalSinceDate:date2];
    int hours =(int) time/3600;
    
    return hours ;
    
}


@end
