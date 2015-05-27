//
//  TimeSelect.m
//  Go2
//
//  Created by IF on 15/4/24.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "TimeSelectView.h"

@interface TimeSelectView ()<UITableViewDataSource, UITableViewDelegate>{
    NSString *_navigationTransition;
    UIView * pickView ;
    ClickWho_StartAndEnd isClickWho;
    NSIndexPath *laterIndexPath ;
    NSMutableDictionary * dataDic ;
    BOOL isStart;
    BOOL isEnd ;
    UIToolbar * toolbar  ;
}

@property (nonatomic,retain) UITableView * tableView;

@end

@implementation TimeSelectView

-(id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES ;
        self.layer.cornerRadius = 5 ;
        [self createNavigationBar];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height-44) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self ;
        [self addSubview:self.tableView] ;
        [self creteInitDateTime];
        [self createDatePicker ];
        [self createToolBar];
    }
    return self;
}


-(void)createNavigationBar{
    UINavigationBar * timeViewBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    UINavigationItem * timeViewBarItem = [[UINavigationItem alloc] initWithTitle:nil];
//    timeViewBarItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invitations_Filled"]
//                                                                          style:UIBarButtonItemStyleDone
//                                                                         target:self
//                                                                         action:@selector(clickTimeRightButton)];
    [timeViewBarItem setTitle:@"Option"];
    [timeViewBar pushNavigationItem:timeViewBarItem animated:NO];
    [self addSubview:timeViewBar];
}

-(void)creteInitDateTime{
    
    NSDate * startDate = [NSDate date];
    NSDate * endDate = [startDate dateByAddingTimeInterval:60*60];
    dataDic = @{startTime:startDate,endTime:endDate}.mutableCopy ;
}

-(void)createDatePicker{
    pickView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 216)];
    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSLog(@"%@",SYS_DEFAULT_TIMEZONE);
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    [datePicker sizeToFit] ;
    [datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    [pickView addSubview:datePicker];
}

-(void)createToolBar{
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44)];
//    UIBarButtonItem * leftButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"    Back    " style:UIBarButtonItemStyleBordered target:self action:@selector(clickTimeSelectToolLeftButton:)] ;
    UIBarButtonItem * rightButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"    Done    " style:UIBarButtonItemStyleBordered target:self action:@selector(/*clickTimeSelectToolRightButton:*/clickTimeRightButton)] ;
    UIBarButtonItem * flexbuttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [toolbar setItems:@[/*leftButtonItem,*/flexbuttonItem,rightButtonItem,flexbuttonItem] animated:YES];
    [self addSubview:toolbar];
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


-(void)clickTimeSelectToolLeftButton:(UIBarButtonItem *) barButtonItem{
    if (self.timeViewDelegate && [self.timeViewDelegate respondsToSelector:@selector(clickTimeSelectToolLeftButton:)]) {
        [self.timeViewDelegate clickTimeSelectToolLeftButton:barButtonItem];
    }
}

-(void)clickTimeSelectToolRightButton:(UIBarButtonItem *) barButtonItem{
    if (self.timeViewDelegate && [self.timeViewDelegate respondsToSelector:@selector(clickTimeSelectToolRightButton:)]) {
        [self.timeViewDelegate clickTimeSelectToolRightButton:barButtonItem];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ( section == 1 ) {
        return 4.f;
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

-(void)clickTimeRightButton{
    NSDate *startDate = [dataDic objectForKey:startTime];
    NSDate *endDate = [dataDic objectForKey:endTime];
    NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    if (interval<=0) {
        [MBProgressHUD showError:@"The start date must be before the end date"] ;
        return;
    }
    if (self.timeViewDelegate && [self.timeViewDelegate respondsToSelector:@selector(timeSelectView:dateDic:)]) {
        [self.timeViewDelegate timeSelectView:self dateDic:dataDic];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSString *)formaterDate:(NSDate *) selectDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d EEE,yyyy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}

@end
