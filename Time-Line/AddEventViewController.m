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
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
@interface AddEventViewController (){
    UITextField* textfiled;
    UILabel *_textlable;
    
    NSMutableDictionary* eventDic;
    UILabel* startlabel;
    UILabel* endlabel;
    NSMutableArray* seledayArr;
    NSArray* alertarr;
    UITextField* localfiled;
    UILabel*_locallable;
    
    
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
   
    
    UILabel *_CAlable;
    
    BOOL isUse;
    
    
   
        
    
    
}

@end

@implementation AddEventViewController
@synthesize state;
@synthesize dateDic;
@synthesize dateArr;
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
    
    endlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 24, self.view.frame.size.width, 0)];
    endlabel.textAlignment=NSTextAlignmentCenter;
    endlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    if ([state isEqualToString:@"edit"]) {
        endlabel.frame=CGRectMake(0, 24, self.view.frame.size.width, 44);
        startlabel.frame=CGRectMake(0, 0, self.view.frame.size.width, 44);
        NSString* starttime=[dateDic objectForKey:@"start"];
        NSRange ranges=[starttime rangeOfString:@"日"];
        NSString* strsend=[starttime substringWithRange:NSMakeRange(0,ranges.location+1)];
        NSString*  endtime=[dateDic objectForKey:@"end"];
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
//        startlabel.text=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyy年 M月d日HH:mm"];
//        endlabel.text=[[PublicMethodsViewController getPublicMethods] getonehourstime:@"yyyy年 M月d日HH:mm"];
        
        startlabel.text=@"TIME";
        
    }
    [self InitUI];
//    UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
//    headview.backgroundColor=[UIColor redColor];
//    
    
    
    
//    addImage=[UIButton buttonWithType:UIButtonTypeCustom];
//    addImage.frame=headview.frame;
    
    
    
    
    
    if ([state isEqualToString:@"edit"]) {
        if ([[dateDic objectForKey:@"url"] isEqualToString:@"photo.png"]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"photo.png"];
            UIImage* image=[UIImage imageWithContentsOfFile:plistPath];
            [addImage setBackgroundImage:image forState:UIControlStateNormal];
            imagename=@"photo.png";
        }else{
            [addImage setBackgroundImage:[UIImage imageNamed:[dateDic objectForKey:@"url"]] forState:UIControlStateNormal];
            imagename=[dateDic objectForKey:@"url"];
        }
        [addImage setTitle:@"CHANGE A PICTURE" forState:UIControlStateNormal];
    }else{
        [addImage setTitle:@"CHOOSE A PICTURE" forState:UIControlStateNormal];
    }
    addImage.titleLabel.textColor=[UIColor whiteColor];
    addImage.titleLabel.textAlignment=NSTextAlignmentCenter;
    addImage.titleLabel.font=[UIFont boldSystemFontOfSize:17.0f];
    [addImage addTarget:self action:@selector(handleSingleTapFrom) forControlEvents:UIControlEventTouchUpInside];
//    [headview addSubview:addImage];
//    self.tableView.tableHeaderView=headview;
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
    
    calendarlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];

    
     self.isOpen = NO;

    
}



//删除事件
-(void)deleteEvent{
    EKEventStore* eventStore=[[EKEventStore alloc]init];
    EKEvent* event=[eventStore eventWithIdentifier:[dateDic objectForKey:@"timeid"]];
    NSError* error=nil;
    [eventStore removeEvent:event span:EKSpanThisEvent error:&error];
//    AppDelegate* app=[[UIApplication sharedApplication] delegate];
//    app.isread=YES;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSMutableDictionary* deldic=[[NSMutableDictionary alloc]initWithCapacity:0];
//    NSArray* valueArr=[data allValues];
//    NSArray* keyarr=[data allKeys];
//
//    for (int i=0; i<[valueArr count]; i++) {
//        NSMutableArray* arr=[valueArr objectAtIndex:i];
//        for (int j=0; j<[arr count]; j++) {
//            NSDictionary* dic=[arr objectAtIndex:j];
//            if ([[dic objectForKey:@"timeid"] isEqualToString:[dateDic objectForKey:@"timeid"]]) {
//                [arr removeObjectAtIndex:j];
//                if ([arr count]==0) {
//                    [data removeObjectForKey:[keyarr objectAtIndex:i]];
//                }else{
//                    [deldic setObject:arr forKey:[keyarr objectAtIndex:i]];
//
//                }
//            }else{
//                [deldic setObject:arr forKey:[[data allKeys] objectAtIndex:i]];
//            }
//        }
//        [deldic writeToFile:plistPath atomically:YES];
//    }
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
    if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//添加事件或保存修改
- (void)onClickAdd
{
    
    
    if (textfiled.text.length<=0) {
       [textfiled becomeFirstResponder];
        return;
    }
    if ([addImage.titleLabel.text isEqualToString:@"CHOOSE A PICTURE"]) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示:" message:@"请选择一张背景图片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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

//        [self getLocalNotification:startlabel.text];
//    NSString* destDateString=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日"];
//    if ([seledayArr count]<=0) {
//        [seledayArr addObject:destDateString];
//    }
//        NSInteger timeid = 0;
//        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"timeid"]) {
//            timeid=[[NSUserDefaults standardUserDefaults] integerForKey:@"timeid"];
//        }
//        timeid++;
//        if ([state isEqualToString:@"edit"]) {
//            timeid=[[dateDic objectForKey:@"timeid"] integerValue];
//        }
//
//     for (NSString* day in seledayArr) {
//        NSMutableArray* array=[[NSMutableArray alloc]initWithCapacity:0];
//        NSDictionary* dic=nil;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
//        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//        NSLog(@"%@",plistPath);
//        if ([data count]>0) {
//            eventDic=data;
//        }
//        if ([day isEqualToString:[seledayArr objectAtIndex:0]]||[day isEqualToString:[seledayArr objectAtIndex:[seledayArr count]-1]]) {
//            dic=[[NSDictionary alloc]initWithObjectsAndKeys:startlabel.text,@"start",endlabel.text,@"end",textfiled.text,@"title",[NSString stringWithFormat:@"%ld",(long)timeid],@"timeid",loclabel.text,@"loc",imagename,@"image",nil];
//        }else{
//            dic=[[NSDictionary alloc]initWithObjectsAndKeys:day,@"start",endlabel.text,@"end",textfiled.text,@"title",[NSString stringWithFormat:@"%ld",(long)timeid],@"timeid",loclabel.text,@"loc",imagename,@"image",nil];
//        }
//        for (NSString* str in [data allKeys]) {
//            if ([str isEqualToString:day]) {
//                for (NSDictionary* temdic in [data objectForKey:str]) {
//                    [array addObject:temdic];
//                }
//            }
//        }
//        [array addObject:dic];
//        [self getLocalNotification:day];
//        [eventDic setObject:array forKey:day];
//        [eventDic writeToFile:plistPath atomically:YES];
//         NSLog(@"----%@",eventDic);
//    }
//         [[NSUserDefaults standardUserDefaults] setInteger:timeid forKey:@"timeid"];
    }
    [textfiled resignFirstResponder];
    if ([state isEqualToString:@"edit"]) {
        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[HomeViewController class]]) {
                [self.navigationController popToViewController:obj animated:YES];
            }
        }
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dissViewcontroller) userInfo:nil repeats:YES];
        
        //    [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)dissViewcontroller{
    if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
       [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)editEvent{
    EKEventStore* eventStore=[[EKEventStore alloc]init];
    EKEvent* event=[eventStore eventWithIdentifier:[dateDic objectForKey:@"timeid"]];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误细心
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                }
                else
                {
                    // access granted
                    // ***** do the important stuff here *****
                    
                    //事件保存到日历
                    
                    //创建事件
                    NSLog(@"%@",imagename);
                    event.title =textfiled.text;
                    event.location =localfiled.text;
                    event.URL=[NSURL URLWithString:imagename];
                    NSRange range=[startString rangeOfString:@"日"];
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    NSString* strs=[startString substringWithRange:NSMakeRange(range.location+1,startString.length-range.location-1)];
                    if (strs.length<=0) {
                        [tempFormatter setDateFormat:@"YYYY年 M月d日"];
                    }else{
                        [tempFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
                    }
                    event.startDate = [tempFormatter dateFromString:startString];
                    NSLog(@"%@---------%@",startString,strs);
                    NSRange ranges=[endString rangeOfString:@"日"];
                    NSDateFormatter *tempFormatters = [[NSDateFormatter alloc]init];
                    NSString* endstrs=[endString substringWithRange:NSMakeRange(ranges.location+1,endString.length-ranges.location-1)];
                    if (endstrs.length<=0) {
                        [tempFormatters setDateFormat:@"YYYY年 M月d日"];
                    }else{
                        [tempFormatters setDateFormat:@"YYYY年 M月d日HH:mm"];
                    }
                    
                    event.endDate   = [tempFormatter dateFromString:endString];
                    event.location =localfiled.text;
                    event.notes=notefiled.text;
                    //                    event.allDay = YES;
                    
                    //添加提醒
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:10.0f]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Event Created"
                                          message:@"Yay!?"
                                          delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
                    [alert show];
                    
                    NSLog(@"保存成功");
                    
                }
            });
        }];
    }


//    NSString* destDateString=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日"];
//    if ([seledayArr count]<=0) {
//        [seledayArr addObject:destDateString];
//    }
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSMutableDictionary* deldic=[[NSMutableDictionary alloc]initWithCapacity:0];
//    NSArray* valueArr=[data allValues];
//    NSArray* keyarr=[data allKeys];
//    for (int i=0; i<[valueArr count]; i++) {
//        NSMutableArray* arr=[valueArr objectAtIndex:i];
//        for (int j=0; j<[arr count]; j++) {
//            NSDictionary* dic=[arr objectAtIndex:j];
//            if ([[dic objectForKey:@"timeid"] isEqualToString:[dateDic objectForKey:@"timeid"]]) {
//                [arr removeObjectAtIndex:j];
//                if ([arr count]==0) {
//                    [data removeObjectForKey:[keyarr objectAtIndex:i]];
//                }else{
//                    [deldic setObject:arr forKey:[keyarr objectAtIndex:i]];
//                    
//                }
//            }else{
//                [deldic setObject:arr forKey:[[data allKeys] objectAtIndex:i]];
//            }
//        }
//        [deldic writeToFile:plistPath atomically:YES];
//    }
//    
//    for (NSString* day in seledayArr) {
//        NSMutableArray* array=[[NSMutableArray alloc]initWithCapacity:0];
//        NSDictionary* dic=nil;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
//        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//        NSLog(@"%@",plistPath);
//        if ([data count]>0) {
//            eventDic=data;
//        }
//        NSInteger timeid=[[dateDic objectForKey:@"timeid"] integerValue];
//        if ([day isEqualToString:[seledayArr objectAtIndex:0]]||[day isEqualToString:[seledayArr objectAtIndex:[seledayArr count]-1]]) {
//            dic=[[NSDictionary alloc]initWithObjectsAndKeys:startlabel.text,@"start",endlabel.text,@"end",textfiled.text,@"title",[NSString stringWithFormat:@"%ld",(long)timeid],@"timeid",loclabel.text,@"loc",nil];
//        }else{
//            dic=[[NSDictionary alloc]initWithObjectsAndKeys:day,@"start",endlabel.text,@"end",textfiled.text,@"title",[NSString stringWithFormat:@"%ld",(long)timeid],@"timeid",loclabel.text,@"loc",nil];
//        }
//        for (NSString* str in [data allKeys]) {
//            if ([str isEqualToString:day]) {
//                for (NSDictionary* temdic in [data objectForKey:str]) {
//                    [array addObject:temdic];
//                }
//            }
//        }
//        [array addObject:dic];
//        //        [self getLocalNotification:day];
//        [eventDic setObject:array forKey:day];
//        [eventDic writeToFile:plistPath atomically:YES];
//        NSLog(@"----%@",eventDic);
//    }


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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section==0||section==2) {
        if (self.isOpen) {
            if (self.selectIndex.section == section) {
                return 3;
            }
        }
//    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row==1||indexPath.row==4) {
//        return 84;
//    }
//    if (indexPath.row==4) {
//        return 64+24*[alarmArray count];
//    }
    
    
    if (indexPath.section==4) {
        if (indexPath.row==0) {
            
            return 200;
        }
    }

    
    
    
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
//        static NSString* cellId2=@"adds";
//        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:cellId2];
//        if (cell2==nil) {
//            cell2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
//        }
//        cell2.textLabel.text=@"1";
//        return cell2;
//
//    }else{
        static NSString* cellId=@"add";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        NSArray*subviews = [[NSArray alloc]initWithArray:cell1.contentView.subviews];
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
        if (indexPath.section==1) {
            if (indexPath.row==0) {
               //cell1.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                [cell1.contentView addSubview:startlabel];
                [cell1.contentView addSubview:endlabel];
            }
        }
        if (indexPath.section==2){
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_locallable];
                [cell1.contentView addSubview:localfiled];
            }
        }
        if (indexPath.section==3){
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_CAlable];
                [cell1 viewWithTag:0];
            }
        }
        if (indexPath.section==4) {
            if (indexPath.row==0) {
    NSArray *array = [[NSArray alloc] initWithObjects:@"Alert_Day.png",@"Alert_Hour.png",@"Alert_Minute.png", nil];
                for (int i=0; i<3; i++)
                {
                    UIImageView*imageview = [[UIImageView alloc] init];
                    imageview.frame = CGRectMake(50+(i*100), 30, 30, 30);
                    imageview.image = [UIImage imageNamed:[array objectAtIndex:i]];
                    [cell1.contentView addSubview:imageview];
                }
    NSArray *arr = [[NSArray alloc] initWithObjects:@"1d",@"0.5h",@"5m",@"2d",@"1h",@"10m",@"7d",@"2h",@"15m", nil];
                for (int i=0; i<9; i++) {
                  UIButton *Btn = [[UIButton alloc] init];
                    Btn.tag = i+10;
                    CGRect frame;
                    frame.size.width = 40;//设置按钮坐标及大小
                    frame.size.height = 20;
                    frame.origin.x = (i%3)*(65+35)+45;
                    frame.origin.y = floor(i/3)*(30+20)+70;
                    [Btn setFrame:frame];
                    [Btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
                    [Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell1.contentView addSubview:Btn];
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
        if (indexPath.section==6)
        {
            if (indexPath.row==0)
            {
               // cell1.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                
                UILabel* alertlabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 44)];
                alertlabel.tag=2000;
                alertlabel.textAlignment=NSTextAlignmentCenter;
                alertlabel.font=[UIFont boldSystemFontOfSize:15.0f];
                alertlabel.textColor=[UIColor blackColor];
                [cell1.contentView addSubview:alertlabel];
                
                
                
                NSArray *Array = [[NSArray alloc] initWithObjects:@"Daily",@"Weekly",@"Monthly", nil];
                
                for (int i=0; i<3; i++)
                {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    button.frame = CGRectMake(30+(i*100), 45, 55, 20);
                    button.tag = i+100;
                     [button setTitle:[Array objectAtIndex:i] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

                    
                    
                    [cell1.contentView addSubview:button];
                }

                
                
                
                
                
                
                
                
            }
            
            
            
        }
        
            localfiled.placeholder=@"LOCATION";
        _locallable.text = @"                          Location";
            notefiled.placeholder=@"Note";
            peoplelabel.text=@"3 Alerts";
            calendarlabel.text=@"                              Note";
        
            _CAlable.text = @"                    Calendar Account";
            UILabel* label=(UILabel*)[cell1 viewWithTag:2000];
            label.text=@"Repeat";

            textfiled.placeholder = @"EVENT TITLE";
            _textlable.text = @"                         Event Title";
        
            if ([state isEqualToString:@"edit"]) {
                startString=[dateDic objectForKey:@"start"];
                endString=[dateDic objectForKey:@"end"];
                startlabel.text=[startString substringFromIndex:5];
                endlabel.text=[endString substringFromIndex:5];
            }
            
            if ([state isEqualToString:@"edit"]) {
                notefiled.text=[dateDic objectForKey:@"note"];
            }
            if ([state isEqualToString:@"edit"]) {
                textfiled.text =[dateDic objectForKey:@"title"];
                localfiled.text=[dateDic objectForKey:@"loc"];
            }
            
            
            return cell1;


//     }
    
    
    
    //        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //        cell.accessoryType=UITableViewCellAccessoryNone;
    
    
    //     if (indexPath.section==4) {
    //         cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    //         for (UILabel* label in [cell.contentView subviews]) {
    //             [label removeFromSuperview];
    //         }
    //        UILabel* alertlabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 44)];
    //        alertlabel.text=@"ALERT";
    //        alertlabel.textAlignment=NSTextAlignmentCenter;
    //        alertlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    //        alertlabel.textColor=[UIColor blackColor];
    //        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]) {
    //            for (int i=0;i<[alarmArray count];i++) {
    //                timealert=[[UILabel alloc]initWithFrame:CGRectMake(0,24+i*24 ,self.view.frame.size.width, 44)];
    //                timealert.textAlignment=NSTextAlignmentCenter;
    //                timealert.font=[UIFont boldSystemFontOfSize:15.0f];
    //                timealert.textColor=[UIColor blackColor];
    //                timealert.text=[alarmArray objectAtIndex:i];
    //                [cell.contentView addSubview:timealert];
    //            }
    //
    //        }else{
    //        timealert=[[UILabel alloc]initWithFrame:CGRectMake(0,24,self.view.frame.size.width, 44)];
    //        timealert.textAlignment=NSTextAlignmentCenter;
    //        timealert.font=[UIFont boldSystemFontOfSize:15.0f];
    //        timealert.textColor=[UIColor blackColor];
    //        timealert.text=@"NONE";
    //        [cell.contentView addSubview:timealert];
    //        }
    //        [cell.contentView addSubview:alertlabel];
    //
   
}
-(void)buttonPressed:(UIButton *)button
{
    
    
    NSLog(@"buttonPressed %d",button.tag);
}
-(void)btnPressed:(UIButton *)btn
{
    //isUse = !isUse;
    
//    if (isUse)
//    {
//        
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        
//    }else
//    {
//        
//        
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
    
    NSLog(@"brnbrnbrnbnr %d",btn.tag);
    
    
    
    switch (btn.tag)
    {
        case 10:
            
            isUse = !isUse;
            
                if (isUse)
                {
            
                    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
                }else
                {
            
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            break;
        default:
            break;
    }
    
    
    
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
    if (self.isOpen) [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark settimedelegate
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

#pragma mark getlocationDelegate
-(void)getlocation:(NSString *)loc{
    if (loc.length>0) {
        localfiled.text=loc;
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
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    self.tableView.frame=CGRectMake(0, -150, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    
    [UIView commitAnimations];

        
      NSLog(@"开始编辑");
    
    
    
}


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


- (void)postEvent{
    //事件市场
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误细心
                    // display error message here
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                    // display access denied error message here
                }
                else
                {
                    // access granted
                    // ***** do the important stuff here *****
                    
                    //事件保存到日历
                    
                    
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title =textfiled.text;
                    event.location =localfiled.text;
                    event.URL=[NSURL URLWithString:imagename];
                    NSLog(@"%@-------%@",imagename,event.URL);
                    NSRange range=[startString rangeOfString:@"日"];
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    NSString* strs=[startString substringWithRange:NSMakeRange(range.location+1,startString.length-range.location-1)];
                    if (strs.length<=0) {
                        [tempFormatter setDateFormat:@"YYYY年 M月d日"];
                    }
                    else{
                        [tempFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
                    }
                    event.startDate = [tempFormatter dateFromString:startString];
                    NSLog(@"%@---------%@",[tempFormatter dateFromString:startString],event.eventIdentifier);
                    NSRange ranges=[endString rangeOfString:@"日"];
                    NSDateFormatter *tempFormatters = [[NSDateFormatter alloc]init];
                    NSString* endstrs=[endString substringWithRange:NSMakeRange(ranges.location+1,endString.length-ranges.location-1)];
                    if (endstrs.length<=0) {
                        [tempFormatters setDateFormat:@"YYYY年 M月d日"];
                    }
                    else {
                        [tempFormatters setDateFormat:@"YYYY年 M月d日HH:mm"];
                    }
                    
                    event.endDate= [tempFormatter dateFromString:endString];
                    event.location = localfiled.text;
                    event.notes=notefiled.text;
//                    event.allDay = YES;
                    NSLog(@"%@",[tempFormatter dateFromString:startString]);
                    //添加提醒

                    NSLog(@"%@",seledayArr);

                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
                    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[tempFormatter dateFromString:startString]]];
                    [seledayArr removeObjectAtIndex:0];
                    for (NSString* str in seledayArr) {
                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
                        [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[tempFormatter dateFromString:[NSString stringWithFormat:@"%@08:00",str]]]];
                    }
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    BOOL bSave = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    NSLog(@"保存成功---%d",bSave);

                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Event Created"
                                          message:@"Yay!?"
                                          delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
                    [alert show];
                }
            });
        }];
    }
//    else
//    {
//        // this code runs in iOS 4 or iOS 5
//        // ***** do the important stuff here *****
//        
//        //4.0和5.0通过下述方式添加
//        
//        //保存日历
//        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
//        event.title     = @"哈哈哈，我是日历事件啊";
//        event.location = @"我在杭州西湖区留和路";
//        
//        NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
//        [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
//        
//        event.startDate = [[NSDate alloc]init ];
//        event.endDate   = [[NSDate alloc]init ];
//        event.allDay = YES;
//        
//        
//        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
//        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
//        
//        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//        NSError *err;
//        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Event Created"
//                              message:@"Yay!?"
//                              delegate:nil
//                              cancelButtonTitle:@"Okay"
//                              otherButtonTitles:nil];
//        [alert show];
//        
//        NSLog(@"保存成功");
//        
//    }
}


@end
