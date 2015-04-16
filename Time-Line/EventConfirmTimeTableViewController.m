//
//  EventConfirmTimeTableViewController.m
//  Time-Line
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "EventConfirmTimeTableViewController.h"
#import "DateVoteShowTableViewCell.h"

@interface EventConfirmTimeTableViewController ()

@end

@implementation EventConfirmTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm Event Time" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventSettingView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setFrame:CGRectMake(0, 0, 35, 18)];
//    [rightBtn setTag:2];
//    [rightBtn setTitle:@"Edit" forState:UIControlStateNormal] ;
//    [rightBtn addTarget:self action:@selector(backToEventSettingView:) forControlEvents:UIControlEventTouchUpInside] ;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.timeArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DateVoteShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"voteTimeCellID"];
    if (!cell) {
        cell = (DateVoteShowTableViewCell *)[[[UINib nibWithNibName:@"DateVoteShowTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    }
    ActiveTimeVoteMode * activeTime = self.timeArr[indexPath.section];
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    
    NSDate  * startDate = [dateFormatter dateFromString:activeTime.startTime] ;
    NSDate  * endDate   = [dateFormatter dateFromString:activeTime.endTime] ;
    
    cell.startTimeOrDay.text = [NSString stringWithFormat:@"From - %@",[self formaterDate:startDate] ]  ;
    cell.timeOrEenTime.text  = [NSString stringWithFormat:@"  To - %@",[self formaterDate:endDate]];
    
    UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [selectBtn setTitle:@"SELECT" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [selectBtn setTitleColor:purple forState:UIControlStateSelected];
    selectBtn.tag =  [activeTime.Id integerValue];
    [selectBtn addTarget:self action:@selector(comfirmActiveTime:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = selectBtn ;
    cell.showTimeInterval.text = @"0";
    return cell;
}

-(void)comfirmActiveTime:(UIButton *)sender{
    sender.selected = NO ;
    ASIHTTPRequest *request = [t_Network httpGet:@{ @"eid":self.eid, @"tid":@(sender.tag) }.mutableCopy Url:anyTime_ConfirmEventTime Delegate:nil Tag:anyTime_ConfirmEventTime_tag];
    __block ASIHTTPRequest *aliasRequest = request;
    [request setCompletionBlock: ^{
        NSString *responseStr = [aliasRequest responseString];
        id objGroup = [responseStr objectFromJSONString];
        if ([objGroup isKindOfClass:[NSDictionary class]]) {
            NSString *statusCode = [objGroup objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                sender.selected = YES ;
                if (self.delegate && [self.delegate respondsToSelector:@selector(eventConfirmTimeTableViewControllerDelegate:setTimeId:)]) {
                    [self.delegate eventConfirmTimeTableViewControllerDelegate:self setTimeId:[NSString stringWithFormat:@"%i",sender.tag]];
                }
            }
        }
    }];
    [request setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error!"];
    }];
    [request startAsynchronous];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)backToEventSettingView:(UIButton *) sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 2:{
            
        }break;
 
        default:
            break;
    }
}


-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d EEE,yyyy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}
@end
