//
//  AllDateViewController.m
//  Time-Line
//
//  Created by IF on 15/3/27.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//


#import "AllDateViewController.h"
#import "AddMoreViewController.h"



typedef NS_ENUM(NSInteger, ClickWho_StartAndEnd) {
    ClickWho_StartAndEnd_Default = 0,
    ClickWho_StartAndEnd_Start = 1 ,
    ClickWho_StartAndEnd_End = 2
};


@interface AllDateViewController (){
    NSString *_navigationTransition;
    UIView * pickView ;
    ClickWho_StartAndEnd isClickWho;
    NSIndexPath *laterIndexPath ;
    NSMutableDictionary * dataDic ;
    BOOL isStart;
    BOOL isEnd ;
    
}
@end

@implementation AllDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.cornerRadius = 3.0;
    [self creteInitDateTime];
    [ self createDatePicker ];
    
}

-(void)creteInitDateTime{
    NSDate * startDate = [NSDate date];
    NSDate * endDate = [startDate dateByAddingTimeInterval:60*60];
    dataDic = @{startTime:startDate,endTime:endDate}.mutableCopy ;
}

-(void)createDatePicker{
     pickView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 216)];
    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSLog(@"%@",SYS_DEFAULT_TIMEZONE);
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    [datePicker sizeToFit] ;
    [datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    [pickView addSubview:datePicker];
}


-(void)datePickerDateChanged:(UIDatePicker *)datePicker{
     NSDate *selectDate = [datePicker date];
    
    if (isStart) {
        [dataDic  removeObjectForKey:startTime];
        [dataDic setObject:selectDate forKey:startTime];
    }
    if (isEnd) {
        [dataDic  removeObjectForKey:endTime];
        [dataDic setObject:selectDate forKey:endTime];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[laterIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ( section == 0 ) {
        return 44.f;
    }else {
        return 0.01f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isClickWho == ClickWho_StartAndEnd_Start){
        if (section == 0) {
            return 2;
        }
    }else if(isClickWho == ClickWho_StartAndEnd_End){
        if (section == 1) {
            return 2;
        }
    }
    return 1;
        
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isClickWho == ClickWho_StartAndEnd_Start){
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                return 216.f;
            }
        }
    }else if(isClickWho == ClickWho_StartAndEnd_End){
        if (indexPath.section == 1) {
            if (indexPath.row == 1) {
                return 216.f;
            }
        }
    }
    return 44.f;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"Starts:" ;
        
        cell.detailTextLabel.text = [self formaterDate:[dataDic objectForKey:startTime]] ;
    }
    
    if(isClickWho == ClickWho_StartAndEnd_Start){
        if (indexPath.section == 0 && indexPath.row == 1) {
               cell.selectionStyle = UITableViewCellSelectionStyleNone ;
               [cell.contentView addSubview:pickView] ;
        }
    }
    
    if (indexPath.section == 1){
        if (indexPath.row == 0) {
          cell.textLabel.text = @"Ends:" ;
          cell.detailTextLabel.text = [self formaterDate:[dataDic objectForKey:endTime]] ;
        }
    }
    
    if(isClickWho == ClickWho_StartAndEnd_End){
        if (indexPath.section == 1 && indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            [cell.contentView addSubview:pickView] ;
        }
    }
   
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

#pragma mark - Table View Delegate

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (!isStart) {
                isStart = YES ;
                isEnd = NO ;
                
                isClickWho = ClickWho_StartAndEnd_Start ;
                laterIndexPath = indexPath ;
            }
            [self.tableView reloadData];
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (!isEnd) {
                isEnd = YES ;
                isStart = NO ;
                
                isClickWho = ClickWho_StartAndEnd_End ;
                laterIndexPath = indexPath ;
            }
            [self.tableView reloadData];
        }
    }
    
    
}

- (IBAction)addMoreDateTime:(id)sender {
    AddMoreViewController * addMoreVc = [[AddMoreViewController alloc] init] ;
    [self presentViewController:addMoreVc animated:YES completion:nil];
    
}

#pragma mark - Custom Methods

-(IBAction)dismissModal:(id)sender {
    NSDate *startDate = [dataDic objectForKey:startTime];
    NSDate *endDate = [dataDic objectForKey:endTime];
    NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    if (interval<=0) {
        [MBProgressHUD showError:@"The start date must be before the end date"] ;
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(allDateViewController:dateDic:)]) {
        [self.delegate allDateViewController:self dateDic:dataDic];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d EEE,yyyy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}

@end


