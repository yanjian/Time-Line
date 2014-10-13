//
//  AddEventViewController.m
//  Time-Line
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "AddEventViewController.h"
#import "ViewController.h"
#import "CLEvent.h"
#import "AlertViewController.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "GoogleMapViewController.h"
#import "AnyEvent.h"


#define TITLE     @"eventTitle"
#define LOCATION  @"location"
#define STARTDATE  @"startDate"
#define ENDDATE    @"endDate"
#define NOTE       @"note"
#define CACCOUNT   @"calendarAccount"
#define ALERTS     @"alerts"
#define COORDINATE @"coordinate"
#define  REPEAT    @"repeat"

@interface AddEventViewController () <ASIHTTPRequestDelegate>
{
    UITextField* textfiled;
    UILabel *_textlable;
    
    NSMutableDictionary* eventDic;
    UILabel* startlabel;
    UILabel* endlabel;
    NSMutableArray* seledayArr;
    NSArray* alertarr;
    
    UITextField* localfiled;
    UILabel*_locallable;
    UIButton *_localtionBtn;//地图点击事件
    UIImageView *addressIcon;
    
    NSMutableArray *alertButtonArr;//存放alert按钮
    NSMutableArray *selectAlertArr;//存放用户选择的提醒时间
    NSMutableArray *repeatButtonArr;//事件重复
    NSMutableArray *selectRepeatArr;//现在的重复事件 如：每天，每周，等
    
    UIButton* addImage;
    NSString* imagename;
    UITextField* notefiled;
    UILabel* people;
    UILabel* calendar;
    NSString* startString;
    NSString* endString;
    NSMutableArray* alarmArray;
    UILabel* timealert;
    UILabel* peoplelabel;
    UILabel* calendarlabel;
    NSDictionary *coordinates;
    UILabel *_CAlable;
    BOOL isUse;
    BOOL isReadFlag;//编辑是取数据只执行一次！
    
}
@property (nonatomic,assign) BOOL isShowMap;//地图是否显示
@property (nonatomic,assign) NSInteger alertCount;//设置的闹钟数

@end

@implementation AddEventViewController

@synthesize state,dateDic,dateArr,event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.barTintColor = blueColor;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Cross.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 20, 20)];
    [leftBtn addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    
    UIButton*  rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn_arrow setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
    [rightBtn_arrow setFrame:CGRectMake(0, 2, 25, 20)];
    [rightBtn_arrow addTarget:self action:@selector(onClickAdd) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_arrow];
    
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:rightView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [rightView addSubview:titlelabel];
    self.navigationItem.titleView =rightView;
    
    titlelabel.text = @"New Event";
    if ([state isEqualToString:@"edit"]) {
        titlelabel.text=@"Edit Event";
    }

    seledayArr=[[NSMutableArray alloc]initWithCapacity:0];
    eventDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    startlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 84)];
    startlabel.textAlignment=NSTextAlignmentCenter;
    startlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    
    alertButtonArr=[[NSMutableArray alloc] initWithCapacity:0];//存放alert按钮的array
    selectAlertArr=[[NSMutableArray alloc] initWithCapacity:0];
    repeatButtonArr=[[NSMutableArray alloc] initWithCapacity:0];//存放事件重复周期
    selectRepeatArr=[[NSMutableArray alloc] initWithCapacity:0];
    
    
    endlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 24, self.view.frame.size.width, 0)];
    endlabel.textAlignment=NSTextAlignmentCenter;
    endlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    if ([state isEqualToString:@"edit"]) {
        endlabel.frame=CGRectMake(0, 24, self.view.frame.size.width, 44);
        startlabel.frame=CGRectMake(0, 0, self.view.frame.size.width, 44);
        NSString* starttime=event.startDate;
        NSRange ranges=[starttime rangeOfString:@"日"];
        NSString* strsend=[starttime substringWithRange:NSMakeRange(0,ranges.location+1)];
        NSString*  endtime=event.endDate;
        NSRange range=[endtime rangeOfString:@"日"];
        NSString* end=[endtime substringWithRange:NSMakeRange(0,range.location+1)];
        seledayArr=[[PublicMethodsViewController getPublicMethods] intervalSinceNow:end getStrart:strsend];
        startlabel.text=starttime;
        endlabel.text=endtime;
        
        UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor=[UIColor redColor];
        button.frame=CGRectMake(20, 2, 280, 40);
        [button setTitle:@"Delete Event" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteEvent) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:button];
        self.tableView.tableFooterView=headview;
    }else{
        startlabel.text=@"TIME";
    }
    
    [self InitUI];
    
//    //批注：这个没有什么用，放后删除
//    if ([state isEqualToString:@"edit"]) {
//        if ([[dateDic objectForKey:@"url"] isEqualToString:@"photo.png"]) {
//            NSString *plistPath = setSysDocumentsDir(@"photo.png");
//            UIImage* image=[UIImage imageWithContentsOfFile:plistPath];
//            [addImage setBackgroundImage:image forState:UIControlStateNormal];
//            imagename=@"photo.png";
//        }else{
//            [addImage setBackgroundImage:[UIImage imageNamed:[dateDic objectForKey:@"url"]] forState:UIControlStateNormal];
//            imagename=[dateDic objectForKey:@"url"];
//        }
//        [addImage setTitle:@"CHANGE A PICTURE" forState:UIControlStateNormal];
//    }else{
//        [addImage setTitle:@"CHOOSE A PICTURE" forState:UIControlStateNormal];
//    }
    
    addImage.titleLabel.textColor=[UIColor whiteColor];
    addImage.titleLabel.textAlignment=NSTextAlignmentCenter;
    addImage.titleLabel.font=[UIFont boldSystemFontOfSize:17.0f];
    [addImage addTarget:self action:@selector(handleSingleTapFrom) forControlEvents:UIControlEventTouchUpInside];
  }

-(void)InitUI{
    _textlable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    textfiled=[[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
    textfiled.delegate = self;
    textfiled.tag = 3;
    textfiled.font=[UIFont boldSystemFontOfSize:15.0f];
    textfiled.textAlignment=NSTextAlignmentCenter;
    [textfiled setBorderStyle:UITextBorderStyleNone];
    
    _locallable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    localfiled=[[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
    localfiled.textAlignment=NSTextAlignmentCenter;
    localfiled.font=[UIFont boldSystemFontOfSize:15.0f];
    localfiled.tag=1;
    localfiled.delegate=self;
    
    _localtionBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _localtionBtn.frame=CGRectMake(5, 0, self.view.frame.size.width-10, 164);
    _localtionBtn.showsTouchWhenHighlighted=NO;
    _localtionBtn.backgroundColor=[UIColor clearColor];
    [_localtionBtn addTarget:self action:@selector(openMapDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    addressIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adress_Icon"]];
    
    
    //alert按钮初始化
    NSArray *arr = [[NSArray alloc] initWithObjects:@"1d",@"0.5h",@"5m",@"2d",@"1h",@"10m",@"7d",@"2h",@"15m", nil];
    for (int i=0; i<arr.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i+10;
        CGRect frame;
        frame.size.width = 40;//设置按钮坐标及大小
        frame.size.height = 20;
        frame.origin.x = (i%3)*(65+35)+45;
        frame.origin.y = floor(i/3)*(30+20)+70;
        [btn setFrame:frame];
        [btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [alertButtonArr addObject:btn];
    }
    
    
    NSArray *Array = [[NSArray alloc] initWithObjects:@"Daily",@"Weekly",@"Monthly", nil];
    for (int i=0; i<Array.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(30+(i*100), 45, 55, 20);
        button.tag = i+100;
        [button setTitle:[Array objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [repeatButtonArr addObject:button];
    }
    
    _CAlable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];

    notefiled=[[UITextField alloc]initWithFrame:CGRectMake(0,20,self.view.frame.size.width, 64)];
    notefiled.tag=2;
    notefiled.delegate=self;
    notefiled.textAlignment=NSTextAlignmentCenter;
    notefiled.font=[UIFont boldSystemFontOfSize:15.0f];
    notefiled.textColor=[UIColor blackColor];

    peoplelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    peoplelabel.backgroundColor=[UIColor clearColor];
    peoplelabel.textAlignment=NSTextAlignmentCenter;
    peoplelabel.font=[UIFont boldSystemFontOfSize:15.0f];
    peoplelabel.text=@"0 Alerts";
    calendarlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    
     self.isOpen = NO;
     self.isShowMap=NO;
}



//删除事件
-(void)deleteEvent{
    
    NSArray *eventArr=[[NSArray alloc] initWithObjects:event, nil];
    [NSManagedObject deleteObjects_sync:eventArr];
    for (UIViewController* obj in [self.navigationController viewControllers]) {
        if ([obj isKindOfClass:[HomeViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    alarmArray=[[NSMutableArray alloc]initWithCapacity:0];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]) {
        alarmArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"alert"];
    }
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//取消返回
- (void)onClickCancel
{
   // if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
        //return;
  //  }
    //[self dismissViewControllerAnimated:YES completion:nil];
}

//添加事件或保存修改
- (void)onClickAdd
{
    
    NSLog(@"点击保存数据");
    if (textfiled.text.length<=0) {
       [textfiled becomeFirstResponder];
       // [g_AppDelegate showActivityView:@"Please enter Event Title" interval:.5];
        return;
    }
    if ([startlabel.text isEqualToString:@"CHOOSE"])
    {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示:" message:@"请选择时间" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([state isEqualToString:@"edit"]) {
        [self editEvent];
    }else{
      [self postEvent];
    }
    [textfiled resignFirstResponder];
    if ([state isEqualToString:@"edit"]) {
        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[HomeViewController class]]) {
                [self.navigationController popToViewController:obj animated:YES];
            }
        }
    }else {
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dissViewcontroller) userInfo:nil repeats:YES];
        
        //    [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)dissViewcontroller{
    //if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
   // }else{
    //   [self dismissViewControllerAnimated:YES completion:nil];
   // }
}

//修改事件数据
-(void)editEvent{
    
    NSMutableDictionary *dataDic=[[NSMutableDictionary alloc] initWithCapacity:0];
    [dataDic setObject:textfiled.text forKey:TITLE];
    [dataDic setObject:localfiled.text forKey:LOCATION];
    [dataDic setObject:startString forKey:STARTDATE];
    [dataDic setObject:endString forKey:ENDDATE];
    [dataDic setObject:notefiled.text forKey:NOTE];
    NSString *coor=@"";
    if (coordinates) {
        coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }
    [dataDic setObject:coor forKey:COORDINATE];
    
    NSString * alertStr=@"";
    if( selectAlertArr) {
        alertStr=[selectAlertArr componentsJoinedByString:@","];
    }
    [dataDic setObject:alertStr forKey:ALERTS];
    [dataDic setObject:localfiled.text forKey:CACCOUNT];
    
    
    NSString * repeatStr=@"";
    if(selectRepeatArr) {
        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
    }
    [dataDic setObject:repeatStr forKey:REPEAT];
    
    [NSManagedObject updateObject_sync:event params:dataDic];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textfiled resignFirstResponder];
    [localfiled resignFirstResponder];
    [notefiled resignFirstResponder];
    return YES;
}
//
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (!self.selectIndex) {
//        self.selectIndex = 0;
//        [self didSelectCellRowFirstDo:YES nextDo:NO];
//        
//    }else
//    {
//        [self didSelectCellRowFirstDo:NO nextDo:YES];
//    }
//    return YES;
//}


-(void)textFieldDidEndEditing:(UITextField *)textField{
//    if (textField.tag==1||textField.tag==2) {
//        self.tableView.frame=CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
//        
//    }
    
    self.tableView.frame=CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);

    
    
    if (textField.text.length>0) {
    NSArray* random=[[NSArray alloc]initWithObjects:@"Random_02.jpg",@"Random_04.jpg",@"Random_06.jpg",@"Random_11.jpg",@"Random_12.jpg", nil];
    NSInteger randoms=[self getRandomNumber:0 to:[random count]-1];
    [addImage setBackgroundImage:[UIImage imageNamed:[random objectAtIndex:randoms]] forState:UIControlStateNormal];
    imagename=[random objectAtIndex:randoms];
    NSArray* friendArray=[[NSArray alloc]initWithObjects:@"hangout",@"gathering",@"adventure",@"Hangout",@"Gathering",@"Adventure",nil];
    NSArray* concertarray=[[NSArray alloc]initWithObjects:@"concert",@"music",@"Concert",@"Music",nil];
    NSArray* cyclingArray=[[NSArray alloc]initWithObjects:@"cycling",@"Cycling", nil];
    NSArray* exhibitionarray=[[NSArray alloc]initWithObjects:@"exhibition",@"art",@"Exhibition",@"Art",nil];
    NSArray* hikingArray=[[NSArray alloc]initWithObjects:@"hiking",@"Hiking", nil];
    NSArray* callArray=[[NSArray alloc]initWithObjects:@"call",@"Call", nil];
    NSArray* lectureArray=[[NSArray alloc]initWithObjects:@"lecture",@"Lecture", nil];
    NSArray* movieArray=[[NSArray alloc]initWithObjects:@"birthday",@"Birthday", nil];
    
    NSArray* friendArray1=[[NSArray alloc]initWithObjects:@"Friends_01.jpg",@"Friends_02.jpg",@"Friends_03.jpg",nil];
    NSArray* concertarray1=[[NSArray alloc]initWithObjects:@"Concert_01.jpg",nil];
    NSArray* cyclingArray1=[[NSArray alloc]initWithObjects:@"Cycling_01.jpg", nil];
    NSArray* exhibitionarray1=[[NSArray alloc]initWithObjects:@"Exhibition_01.jpg",nil];
    NSArray* hikingArray1=[[NSArray alloc]initWithObjects:@"Hiking_02.jpg",@"Hiking_04.jpg", nil];
    NSArray* callArray1=[[NSArray alloc]initWithObjects:@"Call_01.jpg", nil];
    NSArray* lectureArray1=[[NSArray alloc]initWithObjects:@"Lecture_01.jpg", nil];
    NSArray* movieArray1=[[NSArray alloc]initWithObjects:@"Movie_01.jpg", nil];
    for (NSString* str in friendArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[friendArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[friendArray1 objectAtIndex:random]] forState:UIControlStateNormal];
            imagename=[friendArray1 objectAtIndex:random];
            return;
        }
    }
    for (NSString* str in concertarray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[concertarray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[concertarray1 objectAtIndex:random]] forState:UIControlStateNormal];
            imagename=[concertarray1 objectAtIndex:random];
            return;

        }
        
    }
    for (NSString* str in cyclingArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[cyclingArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[cyclingArray1 objectAtIndex:random]] forState:UIControlStateNormal];
            imagename=[cyclingArray1 objectAtIndex:random];
            return;
        }
    }
    
    for (NSString* str in exhibitionarray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[exhibitionarray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[exhibitionarray1 objectAtIndex:random]] forState:UIControlStateNormal];
             imagename=[exhibitionarray1 objectAtIndex:random];
            return;
        }
    }
    
    for (NSString* str in hikingArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[hikingArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[hikingArray1 objectAtIndex:random]] forState:UIControlStateNormal];
            imagename=[hikingArray1 objectAtIndex:random];
            return;
        }
    }
    
    for (NSString* str in callArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[callArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[callArray1 objectAtIndex:random]] forState:UIControlStateNormal];
             imagename=[callArray1 objectAtIndex:random];
            return;
        }
    }
    
    for (NSString* str in lectureArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[lectureArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[lectureArray1 objectAtIndex:random]] forState:UIControlStateNormal];
              imagename=[lectureArray1 objectAtIndex:random];
            return;
        }
    }
    
    for (NSString* str in movieArray) {
        NSRange range=[textField.text rangeOfString:str];
        if(range.location!=NSNotFound){
            NSInteger random=[self getRandomNumber:0 to:[movieArray1 count]-1];
            [addImage setBackgroundImage:[UIImage imageNamed:[movieArray1 objectAtIndex:random]] forState:UIControlStateNormal];
              imagename=[movieArray1 objectAtIndex:random];
            return;
        }
    }
      [addImage setTitle:@"CHANGE A PICTURE" forState:UIControlStateNormal];
    }
}



-(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random()%(to -from + 1)));
    
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
             return 3;
        }
    }
    if (self.isShowMap) {
        if (2==section) {//当是location时为两行
            return 2;
        }
    }
    
    return 1;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   if (indexPath.section==4) {
        if (indexPath.row==0) {
            return 200;
        }
    }
    if (self.isShowMap) {
        if (indexPath.section==2) {
            if (indexPath.row==1) {
                return 164;
            }
        }
    }
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString* cellId=@"addIdentifier";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        //取消选中行的样式
        cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        //清除contentView中的所有视图
        NSArray *subviews = [[NSArray alloc]initWithArray:cell1.contentView.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
        if (indexPath.section==0) {
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_textlable];
                [cell1.contentView addSubview:textfiled];
                if (![state isEqualToString:@"edit"]) {
                    [textfiled becomeFirstResponder];
                }
            }
        }
        if (indexPath.section==1) {//time 时间显示区
            if (indexPath.row==0) {
               //cell1.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                [cell1.contentView addSubview:startlabel];
                [cell1.contentView addSubview:endlabel];
            }
        }
        if (indexPath.section==2){//地图，地址显示区
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_locallable];
                [cell1.contentView addSubview:localfiled];
                if(localfiled.text.length >0){//地图文本不为空
                    NSString *str = localfiled.text;
                    //计算文本的宽度
                    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
                    CGSize size = [str boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                    addressIcon.frame=CGRectMake( (self.view.bounds.size.width/2-size.width/2)-17,25, 12, 15);
                    [localfiled addSubview:addressIcon ];
                }
            }else if (indexPath.row==1){
                [cell1.contentView addSubview:_localtionBtn];
            }
        }
        if (indexPath.section==3){
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_CAlable];
                [cell1 viewWithTag:0];
            }
        }
        if (indexPath.section==4) {//alerts 提醒
            if (indexPath.row==0) {
                NSArray *array = [[NSArray alloc] initWithObjects:@"Alert_Day.png",@"Alert_Hour.png",@"Alert_Minute.png", nil];
                for (int i=0; i<3; i++)
                {
                    UIImageView*imageview = [[UIImageView alloc] init];
                    imageview.frame = CGRectMake(50+(i*100), 30, 30, 30);
                    imageview.image = [UIImage imageNamed:[array objectAtIndex:i]];
                    [cell1.contentView addSubview:imageview];
                }
                for (UIButton *eachBtn in alertButtonArr) {
                    [cell1.contentView addSubview:eachBtn];
                }
                [cell1.contentView addSubview:peoplelabel];
            }
        }
        if (indexPath.section==5) {
            if (indexPath.row==0) {
                [cell1.contentView addSubview:notefiled];
                [cell1.contentView addSubview:calendarlabel];
            }
        }
        if (indexPath.section==6)//重复提醒事件
        {
            if (indexPath.row==0)
            {
                UILabel* alertlabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 44)];
                alertlabel.tag=2000;
                alertlabel.textAlignment=NSTextAlignmentCenter;
                alertlabel.font=[UIFont boldSystemFontOfSize:15.0f];
                alertlabel.textColor=[UIColor blackColor];
                [cell1.contentView addSubview:alertlabel];
                for (int i=0; i<repeatButtonArr.count; i++)
                {
                    [cell1.contentView addSubview:repeatButtonArr[i]];
                }
            }
        }
        
            localfiled.placeholder=@"LOCATION";
            _locallable.text = @"                          Location";
            notefiled.placeholder=@"Note";
          //  peoplelabel.text=@"0 Alerts";
            calendarlabel.text=@"                              Note";
        
            _CAlable.text = @"                    Calendar Account";
            UILabel* label=(UILabel*)[cell1 viewWithTag:2000];
            label.text=@"Repeat";

            textfiled.placeholder = @"EVENT TITLE";
            _textlable.text = @"                         Event Title";
        
            if ([state isEqualToString:@"edit"]) {
                if (!isReadFlag) {
                    startString=event.startDate;
                    endString=event.endDate;
                    startlabel.text=[startString substringFromIndex:5];
                    endlabel.text=[endString substringFromIndex:5];
                    notefiled.text=event.note;
                    textfiled.text =event.eventTitle;
                    localfiled.text=event.location;
                    
                    //读取alerts数据
                    NSArray *alertItemArr=nil;
                    if (![event.alerts isEqualToString:@""]) {
                        alertItemArr=[event.alerts componentsSeparatedByString:@","];
                    }
                    self.alertCount=alertItemArr.count;
                    peoplelabel.text=[NSString stringWithFormat:@"%ld Alerts",(long)self.alertCount];
                    for (NSString *alertStr in alertItemArr) {
                        for (UIButton *eachBtn in alertButtonArr) {
                            if ([alertStr isEqualToString:[eachBtn currentTitle]]) {
                                [eachBtn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
                                [eachBtn setBackgroundColor:[UIColor clearColor]];
                                [selectAlertArr addObject:[eachBtn currentTitle]];
                                [eachBtn setSelected:YES];
                            }
                        }
                        
                    }
                    
                    //读取repeat数据
                    NSArray *repeatItemArr=nil;
                    if (![event.repeat isEqualToString:@""]) {
                        repeatItemArr=[event.repeat componentsSeparatedByString:@","];
                    }
                    
                    for (NSString *repeatStr in repeatItemArr) {
                        for (UIButton *eachBtn in repeatButtonArr) {
                            if ([repeatStr isEqualToString:[eachBtn currentTitle]]) {
                                [eachBtn setBackgroundColor:[UIColor clearColor]];
                                [selectRepeatArr addObject:[eachBtn currentTitle]];
                                [eachBtn setSelected:YES];
                            }
                       }
                    }
                    NSArray *coorArr=nil;
                    if (![event.coordinate isEqualToString:@""]&&event.coordinate) {
                        NSLog(@"%@",event.coordinate);
                        coorArr= [event.coordinate componentsSeparatedByString:@","];
                    }
                    if ([coorArr count]>0) {
                        [self getlocation:event.location coordinate:@{LATITUDE: [coorArr objectAtIndex:0],LONGITUDE:[coorArr objectAtIndex:1]}];
                    }else{
                        [self getlocation:event.location coordinate: nil];
                    }
                    
                    isReadFlag=YES;//默认只取一次值
              }
          }
    
         return cell1;
}



-(void)openMapDetails:(UIButton *) button
{
    GoogleMapViewController *googleMapCon=[[GoogleMapViewController alloc] init];
    if ([googleMapCon respondsToSelector:@selector(setCoordinateDictionary:)]) {
        [googleMapCon setCoordinateDictionary:coordinates];
    }
    [self.navigationController pushViewController:googleMapCon animated:YES];
    NSLog(@"点击咯地图");
}


//事件重复按钮点击事件
-(void)buttonPressed:(UIButton *)button
{
    NSLog(@"buttonPressed %ld",(long)button.tag);
    if(!button.selected) {
        [button setBackgroundColor:[UIColor clearColor]];
        [selectRepeatArr addObject:[button currentTitle]];
        [button setSelected:YES];
    }else{
        [selectRepeatArr removeObject:[button currentTitle]];
        [button setSelected:NO];
    }
}


-(void)btnPressed:(UIButton *)btn
{
  
    [self publicAlertSeting:btn];
     NSLog(@"按钮tag： %ld",(long)btn.tag);
    for (UIButton *eachBtn in alertButtonArr) {
        if(eachBtn.isSelected){
            NSLog(@"%@",eachBtn.currentTitle);
        }
    }
    
}


-(void)publicAlertSeting:(UIButton *) btn
{
   
    if(!btn.selected) {
        //[btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [selectAlertArr addObject:[btn currentTitle]];
        self.alertCount++;
        [btn setSelected:YES];
    }else{
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [selectAlertArr removeObject:[btn currentTitle]];
        self.alertCount--;
        [btn setSelected:NO];
    }
    peoplelabel.text=[NSString stringWithFormat:@"%ld Alerts",(long)self.alertCount];
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [textfiled resignFirstResponder];
    [localfiled resignFirstResponder];
    [notefiled resignFirstResponder];
    self.tableView.frame=CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    
}



//#pragma mark - tableview delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row==1) {
//        ViewController* controler=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
//        controler.detelegate=self;
//        [self.navigationController pushViewController:controler animated:YES];
//    }
//    if (indexPath.row==2) {
//        LocationViewController* location=[[LocationViewController alloc]initWithNibName:@"LocationViewController" bundle:nil];
//        location.detelegate=self;
//        [self.navigationController pushViewController:location animated:YES];
//    }
//    
//    if (indexPath.row==3) {
//        NotesViewController* notes=[[NotesViewController alloc]initWithNibName:@"NotesViewController" bundle:nil];
//        notes.delegate=self;
//        [self.navigationController pushViewController:notes animated:YES];
//    }
//    if (indexPath.row==4) {
//        AlertViewController* alert=[[AlertViewController alloc]initWithNibName:@"AlertViewController" bundle:nil];
//        [self.navigationController pushViewController:alert animated:YES];
//    }
//    
//}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==1||indexPath.section==3) {
        ViewController* controler=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
        controler.detelegate=self;
        [self.navigationController pushViewController:controler animated:YES];
    }
//    if (indexPath.row == 0) {
//        if ([indexPath isEqual:self.selectIndex]) {
//            self.isOpen = NO;
//            [self didSelectCellRowFirstDo:NO nextDo:NO];
//            self.selectIndex = nil;
//            
//        }else
//        {
//            if (!self.selectIndex) {
//                self.selectIndex = indexPath;
//                [self didSelectCellRowFirstDo:YES nextDo:NO];
//                
//            }else
//            {
//                
//                [self didSelectCellRowFirstDo:NO nextDo:YES];
//            }
//        }
//        
//    }else
//    {
////        NSDictionary *dic = [_dataList objectAtIndex:indexPath.section];
////        NSArray *list = [dic objectForKey:@"list"];
////        NSString *item = [list objectAtIndex:indexPath.row-1];
////        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:item message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil] autorelease];
////        [alert show];
//    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//没有使用到
- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
//    UITableViewCell *cell2 = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndex];
//    [cell2 changeArrowWithUp:firstDoInsert];
    [self.tableView beginUpdates];
    int section = self.selectIndex.section;
    int contentCount = 2;
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	if (firstDoInsert)
    {   [self.tableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [self.tableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	[self.tableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen)
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark - viewController的代理方法 settimedelegate
-(void)getstarttime:(NSString *)start getendtime:(NSString *)end{
    endlabel.frame=CGRectMake(0, 24, self.view.frame.size.width, 44);
    startlabel.frame=CGRectMake(0, 0, self.view.frame.size.width, 44);
    startString=start;
    endString=end;
    startlabel.text=[start substringFromIndex:5];
    endlabel.text=[end substringFromIndex:5];
    NSRange ranges=[start rangeOfString:@"日"];
    NSString* strsend=[start substringWithRange:NSMakeRange(0,ranges.location+1)];
    NSRange range=[end rangeOfString:@"日"];
    NSString* ends=[end substringWithRange:NSMakeRange(0,range.location+1)];
    seledayArr=[[PublicMethodsViewController getPublicMethods] intervalSinceNow:ends getStrart:strsend];
}

#pragma mark -代理方法 -- getlocation:coordinate:
-(void)getlocation:(NSString*) name coordinate:(NSDictionary *) coordinatesDic{
    coordinates =  coordinatesDic;
    if (name.length>0) {
        localfiled.text=name;
        if (coordinatesDic) {
            NSString *coordStr= [NSString stringWithFormat:@"%@,%@",[coordinatesDic objectForKey:LATITUDE],[coordinatesDic objectForKey:LONGITUDE] ];
            NSMutableDictionary *paramDic=@{@"center":coordStr,
                                            @"zoom":@"9",
                                            @"size":@"320x164",
                                            @"sensor":@"false",
                                            @"format":@"PNG",
                                            @"markers":coordStr,
                                            @"language":CurrentLanguage,
                                            @"key":GOOGLE_API_KEY }.mutableCopy;
            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:GOOGLE_ADDRESS_PIC Delegate:self Tag:GOOGLE_ADDRESS_PIC_TAG];
            [request startAsynchronous];
            self.isShowMap=YES;
        }else{
            self.isShowMap=NO;
        }
        [self.tableView reloadData];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    NSError * error=[request error];
    if (error) {
        NSLog(@"请求数据出错：%@",error.debugDescription);
        return;
    }
    if (request.responseString||![@"" isEqualToString:request.responseString]) {
         [_localtionBtn setBackgroundImage:[UIImage imageWithData:[request responseData]] forState:UIControlStateNormal];
    }else{
        NSLog(@"图片空。。。。。！");
    }
}


#pragma mark getnotesdelegate
-(void)getnotes:(NSString *)notestr{
    NSLog(@"%@",notestr);
    if (notestr.length>0) {
        notefiled.text=notestr;
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!(3==textField.tag)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.tableView.frame=CGRectMake(0, -200, self.tableView.frame.size.width, self.tableView.frame.size.height);
        [UIView commitAnimations];
    }
    NSLog(@"%ld",textField.tag);
    if ([@"1" isEqualToString:[NSString stringWithFormat:@"%ld",textField.tag] ]) {
        LocationViewController *locationView=[[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
        locationView.detelegate=self;
        [self.navigationController pushViewController:locationView animated:NO];
    }
    
}






-(void)getLocationNotification:(NSMutableDictionary *) eventDictionary
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月d日HH:mm"];
        //触发通知的时间
        NSDate *now = [formatter dateFromString:[eventDictionary valueForKey:STARTDATE]];
        notification.fireDate = now;
        //时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        //通知重复提示的单位，可以是天、周、月
        NSArray *repeatDateArr=[eventDictionary valueForKey:REPEAT];
        if(repeatDateArr){
            for (NSString *repeatStr in repeatDateArr) {
                if ([@"Daily" isEqualToString:repeatStr]) {
                     notification.repeatInterval = NSDayCalendarUnit;
                }
                if ([@"Weekly" isEqualToString:repeatStr]) {
                    notification.repeatInterval = NSWeekdayCalendarUnit;
                }
                if ([@"Monthly" isEqualToString:repeatStr]) {
                    notification.repeatInterval = NSMonthCalendarUnit;
                }
            }
        }
       
        //通知内容
        NSString *title=[eventDictionary valueForKey:TITLE];
        if (title) {
             notification.alertBody = title;
        }
       
        notification.applicationIconBadgeNumber = 0;
        //通知被触发时播放的声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber+=1;
        //执行通知注册
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


//屏蔽 以前遗留 已有在删
-(void)getLocalNotification:(NSString*)day{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY年 M月d日HH:mm"];
    //触发通知的时间
    NSDate *now = [formatter dateFromString:@"2014年 4月21日21:30"];
    notification.fireDate = now;
    //时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //通知重复提示的单位，可以是天、周、月
    notification.repeatInterval = NSDayCalendarUnit;
    //通知内容
    notification.alertBody = textfiled.text;
    notification.applicationIconBadgeNumber = 0;
    //通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    //执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
   
//    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
//
//	// Get the current date
//    NSRange range=[startlabel.text rangeOfString:@"日"];
//    NSString* strs=[startlabel.text substringWithRange:NSMakeRange(range.location+1,startlabel.text.length-range.location-1)];
//    if (strs.length<=00) {
//        strs=@"8:00";
//    }
//    NSString* sateStr=[NSString stringWithFormat:@"%@%@",day,strs];
//    sateStr=[sateStr stringByReplacingOccurrencesOfString:@"年 " withString:@"-"];
//    sateStr=[sateStr stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
//    sateStr=[sateStr stringByReplacingOccurrencesOfString:@"日" withString:@"-"];
//    sateStr=[sateStr stringByReplacingOccurrencesOfString:@":" withString:@"-"];
//    sateStr=[sateStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
//    NSArray* arr=[sateStr componentsSeparatedByString:@"-"];
//    NSLog(@"%@-------%@",arr,sateStr);
//    NSInteger second=[self gettimemonth:arr];
//    NSDate *now = [NSDate new];
//    NSDate *pushDate =[now dateByAddingTimeInterval:second];
//	NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
//												   fromDate:pushDate];
//	NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
//												   fromDate:pushDate];
//	
//	// Set up the fire time
//    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
//    [dateComps setDay:[dateComponents day]];
//    [dateComps setMonth:[dateComponents month]];
//    [dateComps setYear:[dateComponents year]];
//    [dateComps setHour:[timeComponents hour]];
//	// Notification will fire in one minute
//    [dateComps setMinute:[timeComponents minute]];
//	[dateComps setSecond:[timeComponents second]];
//    NSDate *itemDate = [calendar dateFromComponents:dateComps];
//	NSLog(@"%@",itemDate);
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = pushDate;
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//	
//	// Notification details
//    localNotif.alertBody = textfiled.text;
//	// Set the action button
//    localNotif.alertAction = @"View";
//	
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 0;
//	// Specify custom data for the notification
//    NSDictionary* infoDict=[[NSDictionary alloc]initWithObjectsAndKeys:textfiled.text,@"title",[NSString stringWithFormat:@"开始时间:%@\n结束时间:%@",startlabel.text,endlabel.text],@"content",nil];
//    localNotif.userInfo = infoDict;
//	
//	// Schedule the notification
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
 

}

-(NSInteger)gettimemonth:(NSArray*)arr{
    //得到当前日期
    //得到当前日期
    CFAbsoluteTime currTime=CFAbsoluteTimeGetCurrent();
    CFGregorianDate currenttDate=CFAbsoluteTimeGetGregorianDate(currTime,CFTimeZoneCopyDefault());
    //得到要提醒的日期
    CFGregorianDate clockDate=CFAbsoluteTimeGetGregorianDate(currTime, CFTimeZoneCopyDefault());
    clockDate.hour=[[arr objectAtIndex:3] integerValue];
    clockDate.minute=[[arr objectAtIndex:4] integerValue];
    clockDate.second=1;
    clockDate.month=[[arr objectAtIndex:1] integerValue];
    clockDate.day=[[arr objectAtIndex:2]integerValue];
    NSLog(@"currdata,year=%ld",currenttDate.year);
    //把两个日期存放到tm类型的变量中
    struct tm t0,t1;
    t0.tm_year=currenttDate.year - 1900;
    t0.tm_mon=currenttDate.month;
    t0.tm_mday=currenttDate.day;
    t0.tm_hour=currenttDate.hour;
    t0.tm_min=currenttDate.minute;
    t0.tm_sec=currenttDate.second;
    
    t1.tm_year=clockDate.year - 1900;
    t1.tm_mon=clockDate.month;
    t1.tm_mday=clockDate.day;
    t1.tm_hour=clockDate.hour;
    t1.tm_min=clockDate.minute;
    t1.tm_sec=clockDate.second;
    
    NSLog(@"%d",t1.tm_yday);
    NSLog(@"time1=%ld ,time2=%ld",mktime(&t1),mktime(&t0));
    NSTimeInterval time=mktime(&t1)-mktime(&t0);
    if (time<0) {
        t1.tm_wday++;
        time=mktime(&t1)-mktime(&t0);
    }
    NSLog(@"相差%f秒",time);
    return time;
}


#pragma mark getimagename
-(void)handleSingleTapFrom{
    BackGroundViewController* background=[[BackGroundViewController alloc]initWithNibName:@"BackGroundViewController" bundle:nil];
    background.detelegate=self;
    [self.navigationController pushViewController:background animated:YES];
}

-(void)getimage:(NSString *)image{
    NSLog(@"%@",[image substringToIndex:6]);
    if ([[image substringToIndex:6] isEqualToString:@"/Users"]) {
        UIImage* images=[UIImage imageWithContentsOfFile:image];
        imagename=@"photo.png";
        [addImage setBackgroundImage:images forState:UIControlStateNormal];
    }else{
    imagename=image;
    [addImage setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    [addImage setTitle:@"CHANGE A PICTURE" forState:UIControlStateNormal];
}


- (void)postEvent
{
    NSMutableDictionary *dataDic=[[NSMutableDictionary alloc] initWithCapacity:0];
    //[dataDic setObject:[AddEventViewController generateUniqueEventID] forKey:@"eventID"];
    [dataDic setObject:textfiled.text forKey:TITLE];
    [dataDic setObject:localfiled.text forKey:LOCATION];
    [dataDic setObject:startString forKey:STARTDATE];
    [dataDic setObject:endString forKey:ENDDATE];
    [dataDic setObject:notefiled.text forKey:NOTE];
    NSString *coor=@"";
    if (coordinates) {
        coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }
    [dataDic setObject:coor forKey:COORDINATE];

    NSString * alertStr=@"";
    if( selectAlertArr) {
        alertStr=[selectAlertArr componentsJoinedByString:@","];
    }
    [dataDic setObject:alertStr forKey:ALERTS];
    [dataDic setObject:localfiled.text forKey:CACCOUNT];
    
    
    NSString * repeatStr=@"";
    if(selectRepeatArr) {
        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
    }
    [dataDic setObject:repeatStr forKey:REPEAT];
    
    [NSManagedObject addObject_sync:dataDic toTable:NSStringFromClass([AnyEvent class])];
    
    
    
//    
//    //事件存储库
//    NSString *plistPath=getSysDocumentsDir;
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSRange strRange=  [startString rangeOfString:@"日"];
//    NSString *startDate=[startString substringWithRange:NSMakeRange(0, strRange.location+1)];
//    
//    if (!data) {
//         data=[NSMutableDictionary dictionaryWithCapacity:0];
//         NSMutableArray *calendarDataArr=[NSMutableArray arrayWithCapacity:0];
//         NSMutableDictionary *dataDic=[[NSMutableDictionary alloc] initWithCapacity:0];
//        [dataDic setObject:[AddEventViewController generateUniqueEventID] forKey:@"eventID"];
//        [dataDic setObject:textfiled.text forKey:TITLE];
//        [dataDic setObject:localfiled.text forKey:LOCATION];
//        [dataDic setObject:startString forKey:STARTDATE];
//        [dataDic setObject:endString forKey:ENDDATE];
//        [dataDic setObject:notefiled.text forKey:NOTE];
//        if (coordinates) {
//            [dataDic setObject:coordinates forKey:COORDINATE];
//        }
//        [dataDic setObject:selectAlertArr forKey:ALERTS];
//      //[dataDic setObject:localfiled.text forKey:CACCOUNT];
//        [dataDic setObject:selectRepeatArr forKey:REPEAT];
//        [calendarDataArr addObject:dataDic];
//         [self getLocationNotification:dataDic];
//        [data setObject:calendarDataArr forKey:startDate];
//        
//    }else{
//        NSMutableArray *calendarDataArr=[data valueForKey:startDate];
//        if (!calendarDataArr) {
//            calendarDataArr=[[NSMutableArray alloc] initWithCapacity:0];
//            [data setObject:calendarDataArr forKey:startDate];
//        }
//        //用于存放要保存的数据
//        NSMutableDictionary *dataDic=[[NSMutableDictionary alloc] initWithCapacity:0];
//        [dataDic setObject:[AddEventViewController generateUniqueEventID] forKey:@"eventID"];
//        [dataDic setObject:textfiled.text forKey:TITLE];
//        [dataDic setObject:localfiled.text forKey:LOCATION];
//        [dataDic setObject:startString forKey:STARTDATE];
//        [dataDic setObject:endString forKey:ENDDATE];
//        [dataDic setObject:notefiled.text forKey:NOTE];
//        if (coordinates) {
//            [dataDic setObject:coordinates forKey:COORDINATE];
//        }
//        [dataDic setObject:selectAlertArr forKey:ALERTS];
////      [dataDic setObject:localfiled.text forKey:CACCOUNT];
//        [dataDic setObject:selectRepeatArr forKey:REPEAT];
//        [self getLocationNotification:dataDic];
//        [calendarDataArr addObject:dataDic];
//    }
//    [data writeToFile:plistPath atomically:NO];
    
//2014年9月18号屏蔽--------------start-----------yj
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
//    {
//        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (error)
//                {
//                    NSLog(@"error:%@",error);
//                    //错误细心
//                    // display error message here
//                }
//                else if (!granted)
//                {
//                    //被用户拒绝，不允许访问日历
//                    // display access denied error message here
//                }
//                else
//                {
//                    // access granted
//                    // ***** do the important stuff here *****
//                    
//                    //事件保存到日历
//                    
//                    
//                    //创建事件
//                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
//                    event.title =textfiled.text;
//                    event.location =localfiled.text;
//                    event.URL=[NSURL URLWithString:imagename];
//                    NSLog(@"%@-------%@",imagename,event.URL);
//                    NSDate *startDate= [self formatWithStringDate:startString];
//                    event.startDate =startDate;
//                    NSLog(@"%@---------%@",startDate,event.eventIdentifier);
//                    NSDate *endDate=[self formatWithStringDate:endString];
//                    event.endDate= endDate;
//                    event.location = localfiled.text;
//                    event.notes=notefiled.text;
////                  event.allDay = YES;
//                    //添加提醒
//
//                    NSLog(@"%@",seledayArr);
//                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
//                    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:startDate]];
//                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
//                    [seledayArr removeObjectAtIndex:0];
//                    for (NSString* str in seledayArr) {
//                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
//                        [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[tempFormatter dateFromString:[NSString stringWithFormat:@"%@08:00",str]]]];
//                    }
//                    
//                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//                    NSError *err;
//                    BOOL bSave = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//                    NSLog(@"保存成功---%d",bSave);
//
//                    
//                    UIAlertView *alert = [[UIAlertView alloc]
//                                          initWithTitle:@"Event Created"
//                                          message:@"Yay!?"
//                                          delegate:nil
//                                          cancelButtonTitle:@"Okay"
//                                          otherButtonTitles:nil];
//                    [alert show];
//                }
//            });
//        }];
//    }
  
// ----------------------end------------------------
}
@end
