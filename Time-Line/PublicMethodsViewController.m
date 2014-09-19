//
//  PublicMethodsViewController.m
//  Time-Line
//
//  Created by zhoulei on 14-4-19.
//  Copyright (c) 2014年 connor. All rights reserved.
//
#include <math.h>
#import "PublicMethodsViewController.h"

@interface PublicMethodsViewController ()

@end

@implementation PublicMethodsViewController

static PublicMethodsViewController * PublicMethods = nil;
+(PublicMethodsViewController *)getPublicMethods{
    if (PublicMethods == nil) {
        PublicMethods = [[PublicMethodsViewController alloc]init];
    }
    return PublicMethods;
}
-(id)init{
    if (self) {
        
    }
    return self;
}

-(NSString*)getcurrentTime:(NSString*)format{
    NSDate *dates = [NSDate date];
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSString *loctime = [formatter stringFromDate:dates];
    NSLog(@"%@",loctime);
    return loctime;
}

-(NSString *)getonehourstime:(NSString*)format{
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSInteger timer=[timeSp integerValue];
    timer=timer+60*60;
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timer];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

-(NSMutableArray*)intervalSinceNow: (NSString *) theDate getStrart:(NSString*)startdate
{
    NSMutableArray* seledayArr=[[NSMutableArray alloc]initWithCapacity:0];
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY年 M月dd日"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [date dateFromString:startdate];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late-now;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天", timeString];
        
    }
    if (timeString.length<=0) {
        timeString=@"1天";
    }else if([[timeString substringFromIndex:timeString.length-1] isEqualToString:@"钟"]){
        timeString=@"0天";
    }
    if (timeString.length>0&&[[timeString substringFromIndex:timeString.length-1] isEqualToString:@"天"]) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY年 M月d日"];
        NSInteger dd=[[timeString substringToIndex:timeString.length-1] integerValue];
        NSDate* date = [formatter dateFromString:startdate];
        NSInteger time = [[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]] integerValue];
        for (int i=0; i<=dd; i++) {
            NSInteger temtime=time+(24*i*60*60);
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:temtime];
            NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
            [seledayArr addObject:confromTimespStr];
        }
    }
    return seledayArr;
    
}

- (NSString *)timeDifference: (NSString *) theDate getStrart:(NSString*)startdate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY年 M月dd日HH:mm"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [date dateFromString:startdate];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late-now;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ min", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ hr", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ day", timeString];
        
    }
    return timeString;
}

-(NSString*)getseconde:(NSString*)endstart{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
    NSDate *  senddate=[NSDate date];
    //结束时间
    NSDate *endDate = [dateFormatter dateFromString:endstart];
    //当前时间
    NSDate *senderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:senddate]];
    //得到相差秒数
    NSTimeInterval time=[endDate timeIntervalSinceDate:senderDate];
    
     int minute = time/60;
     NSString* dateContent=@"";
    if (minute<60&&minute>0) {
        dateContent=[[NSString alloc] initWithFormat:@"in %i min",minute];
    }else if(minute<0&&minute>-60){
        dateContent=[[NSString alloc] initWithFormat:@"out %i min",(int)fabs(minute)];
    }else{
        int hours = (int)time/3600;
        if(hours<0&&hours>-24){
            dateContent=[[NSString alloc] initWithFormat:@"out %i hr",(int)fabs(hours)];
        }else if(hours>=0){
            dateContent=[[NSString alloc] initWithFormat:@"in %i hr",hours];
        }
    }
    NSLog(@"%f========%i",time,minute);
    return dateContent;

}

- (NSString*)getWeekdayFromDate:(NSDate*)date
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    components = [calendar components:unitFlags fromDate:date];
    NSUInteger weekday = [components weekday];
    NSString* weakStr=@"";
    switch (weekday-1) {
        case 0:
            weakStr=@"Sun";
            break;
        case 1:
            weakStr=@"Mon";
            break;
        case 2:
            weakStr=@"Tue";
            break;
        case 3:
            weakStr=@"Wed";
            break;
        case 4:
            weakStr=@"Thu";
            break;
        case 5:
            weakStr=@"Fri";
            break;
        case 6:
            weakStr=@"Sat";
            break;
        default:
            break;
    }
    
    return weakStr;
}


-(void)setCorner:(UIView *)view radius:(float)cornerRadius borderWidth:(float)width{
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:cornerRadius];
    [view.layer setBorderWidth:width];
    view.layer.borderColor = [[UIColor grayColor] CGColor];
}

-(UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize)newSize{
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    }else{
        UIGraphicsBeginImageContext(newSize);
    }
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    
    return newImage;
}


- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
