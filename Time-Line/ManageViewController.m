//
//  ManageViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ManageViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ActiveEventMode.h"
#import "ActiveTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CalendarDateUtil.h"
#import "ActivedetailsViewController.h"

@interface ManageViewController ()<UITableViewDelegate, UITableViewDataSource,
EGORefreshTableHeaderDelegate,UIScrollViewDelegate,ASIHTTPRequestDelegate,ActivedetailsViewControllerDelegate,UIActionSheetDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSArray * _activeArr;
    NSMutableArray *_tmpActiveArr ;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, naviHigth, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-frame.origin.y) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view  addSubview:self.tableView];
    
    
    _activeArr=[self loadActiveData];
    
    
    if (_refreshHeaderView == nil) {
        //初始化下拉刷新控件
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        refreshView.delegate = self;
        //将下拉刷新控件作为子控件添加到UITableView中
        [self.tableView addSubview:refreshView];
        _refreshHeaderView = refreshView;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return _activeArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 215.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *activeId=@"activeManagerCellId";
    ActiveTableViewCell *activeCell=[tableView dequeueReusableCellWithIdentifier:activeId];
    if (!activeCell) {
        activeCell = (ActiveTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ActiveTableViewCell" owner:self options:nil] firstObject];
    }
    if (_activeArr.count>0) {
        ActiveEventMode *activeEvent = _activeArr[indexPath.section];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:sss"];
        NSTimeZone* timeZone = [NSTimeZone defaultTimeZone];
        [formatter setTimeZone:timeZone];
        if (activeEvent.createTime) {
            NSRange strPoint = [activeEvent.createTime rangeOfString:@"."];
            if (strPoint.location != NSNotFound) {
                activeEvent.createTime = [activeEvent.createTime substringToIndex:strPoint.location];
            }
        }
        
        NSDate * createTime = [formatter dateFromString:activeEvent.createTime];
        NSInteger currMonth = [CalendarDateUtil getMonthWithDate:createTime];
        NSInteger currDay = [CalendarDateUtil getDayWithDate:createTime];
        activeCell.monthLab.text = [self monthStringWithInteger:currMonth];
        activeCell.dayCountLab.text =[NSString stringWithFormat:@"%ld",(long)currDay];
        NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",_urlStr);
        NSURL *url=[NSURL URLWithString:_urlStr];
        [activeCell.activeImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018"]];
        activeCell.activeNameLab.text = activeEvent.title;
        
        UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWithFriendGroup:)];
        [activeCell addGestureRecognizer:longPressGesture];
        
        
    }
    
    return activeCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     ActivedetailsViewController *activeDetailVC = [[ActivedetailsViewController alloc] init];
     ActiveEventMode * activeEvent = _activeArr[indexPath.section];
     activeDetailVC.delegate = self;
     activeDetailVC.activeEvent = activeEvent;
     activeDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
     UINavigationController * nav=[[UINavigationController alloc] initWithRootViewController:activeDetailVC];
     nav.navigationBar.translucent=NO;
     [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



-(NSArray *) loadActiveData{
     _tmpActiveArr= [NSMutableArray arrayWithCapacity:0];
    ASIHTTPRequest * activeRequest = [t_Network httpPostValue:nil Url:anyTime_Events Delegate:self Tag:anyTime_Events_tag];
    
    [activeRequest startAsynchronous];
    return _tmpActiveArr;
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    if (error) {
        [KVNProgress showErrorWithStatus:@"error"];
    }
    NSString * requestStr =  [request responseString];
    NSDictionary * dic = [requestStr objectFromJSONString];
    NSString * statusCode = [dic objectForKey:@"statusCode"];
    if ([@"1" isEqualToString:statusCode]) {
        id dataObj = [dic objectForKey:@"data"];
        
        if ([dataObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic =(NSDictionary *) dataObj;
            NSArray * memberArr =  [dataDic objectForKey:@"member"];
            NSArray * createArr =  [dataDic objectForKey:@"create"];
            if (memberArr.count>0) {
                for (int i = 0; i<memberArr.count; i++) {
                    ActiveEventMode * activeEvent = [[ActiveEventMode alloc ] init];
                    [activeEvent parseDictionary:memberArr[i]];
                    activeEvent.imgUrl = [activeEvent.imgUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    [_tmpActiveArr addObject:activeEvent];
                }
            }
            if (createArr.count>0) {
                for (int i = 0; i<createArr.count; i++) {
                    ActiveEventMode * activeEvent = [[ActiveEventMode alloc ] init];
                    [activeEvent parseDictionary:createArr[i]];
                    activeEvent.imgUrl = [activeEvent.imgUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    [_tmpActiveArr addObject:activeEvent];
                }

            }
        }
        [self.tableView reloadData];
    }else{
        [KVNProgress showErrorWithStatus:@"Request Fail"];
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    
}


- (void)reloadTableViewDataSource
{
    NSLog(@"start");
    _reloading = YES;
    //打开线程，读取下一页数据
    [NSThread detachNewThreadSelector:@selector(requestNext) toTarget:self withObject:nil];
}

- (void)requestNext
{
    //回到主线程跟新界面
    [self performSelectorOnMainThread:@selector(dosomething) withObject:nil waitUntilDone:YES];
}

-(void)dosomething
{
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
}


- (void)doneLoadingTableViewData{
    
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    NSLog(@"end");
}


#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
    
}




- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    //[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}


- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}


-(void)cancelActivedetailsViewController:(ActivedetailsViewController *)activeDetailsViewVontroller{
      _activeArr=[self loadActiveData];//刷新数据
    [activeDetailsViewVontroller dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)handleLongPressWithFriendGroup:(UIGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UIActionSheet * asActiveSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Hide",@"Quit",@"Delete", nil];
        [asActiveSheet showInView:self.view];
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

-(NSString *)monthStringWithInteger:(NSUInteger)month{
    NSString *monthStr;
    switch (month) {
        case 1:
            monthStr = @"JAN";
            break;
        case 2:
            monthStr = @"FEB";
            break;
        case 3:
            monthStr = @"MAR";
            break;
        case 4:
            monthStr = @"APR";
            break;
        case 5:
            monthStr = @"MAY";
            break;
        case 6:
            monthStr = @"JUN";
            break;
        case 7:
            monthStr = @"JUL";
            break;
        case 8:
            monthStr = @"AUG";
            break;
        case 9:
            monthStr = @"SEP";
            break;
        case 10:
            monthStr = @"OCT";
            break;
        case 11:
            monthStr = @"NOV";
            break;
        case 12:
            monthStr = @"DEC";
            break;
            
        default:
            break;
    }
    return monthStr;
}

@end
