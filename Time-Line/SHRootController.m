//
//  SHRootController.m
//  SHLineGraphView
//
//  Created by SHAN UL HAQ on 23/3/14.
//  Copyright (c) 2014 grevolution. All rights reserved.
//

#import "SHRootController.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"

@interface SHRootController (){
    NSMutableArray* seleArray;
    NSMutableArray* coutArr;
    UILabel* eventlabel;
 
}

@end

@implementation SHRootController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = defineBlueColor;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 15, 20)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 140, 40)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =@"首页";
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getevent:) name:@"event" object:nil];
    seleArray=[[NSMutableArray alloc]initWithCapacity:0];
    coutArr=[[NSMutableArray alloc]initWithCapacity:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MYYYY"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString* title=@"";
    switch ([[destDateString substringToIndex:1] integerValue]) {
        case 1:
            title = @"Jan.";
            break;
        case 2:
            title = @"Feb.";
            break;
        case 3:
            title = @"Mar.";
            break;
        case 4:
            title = @"Apr.";
            break;
        case 5:
            title = @"May";
            break;
        case 6:
            title = @"Jun.";
            break;
        case 7:
            title = @"Jul.";
            break;
        case 8:
            title = @"Aug.";
            break;
        case 9:
            title = @"Sept.";
            break;
        case 10:
            title = @"Oct.";
            break;
        case 11:
            title = @"Nov.";
            break;
        case 12:
            title = @"Dec.";
            break;
            
        default:
            break;
    }
    NSRange range=NSMakeRange(0, 1);
    self.title=[destDateString stringByReplacingCharactersInRange:range withString:title];
    [self getdaydate];
    [self readData];
    SHLineGraphView *_lineGraph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(-65, 0, 385, 320)];
    
    NSDictionary *_themeAttributes = @{
                                       kXAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                                       kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kYAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                                       kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kYAxisLabelSideMarginsKey : @20,
                                       kPlotBackgroundLineColorKye : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]
                                       };
    _lineGraph.themeAttributes = _themeAttributes;
    
    _lineGraph.yAxisRange = @(10);
    
    _lineGraph.xAxisValues = @[
                               @{ @1 : @"一" },
                               @{ @2 : @"二" },
                               @{ @3 : @"三" },
                               @{ @4 : @"四" },
                               @{ @5 : @"五" },
                               @{ @6 : @"六" },
                               @{ @7 : @"七" }
                               ];
    
    SHPlot *_plot1 = [[SHPlot alloc] init];
    
    
    NSMutableArray* arr=[[NSMutableArray alloc]initWithCapacity:0];
    for (int i=0;i<[coutArr count];i++) {
        NSMutableDictionary* dic=[[NSMutableDictionary alloc]initWithCapacity:0];
        [dic setObject:[coutArr objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i+1]];
        [arr addObject:dic];
    }
    _plot1.plottingValues =arr;
    
    _plot1.plottingPointsLabels = coutArr;
    
    NSDictionary *_plotThemeAttributes = @{
                                           kPlotFillColorKey : [UIColor colorWithRed:0.47 green:0.75 blue:0.78 alpha:0.5],
                                           kPlotStrokeWidthKey : @2,
                                           kPlotStrokeColorKey : [UIColor colorWithRed:0.18 green:0.36 blue:0.41 alpha:1],
                                           kPlotPointFillColorKey : [UIColor colorWithRed:0.18 green:0.36 blue:0.41 alpha:1],
                                           kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:18]
                                           };
    
    _plot1.plotThemeAttributes = _plotThemeAttributes;
    [_lineGraph addPlot:_plot1];
    
    //You can as much `SHPlots` as you can in a `SHLineGraphView`
    
    [_lineGraph setupTheView];
    
    [self.view addSubview:_lineGraph];
    
    eventlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _lineGraph.frame.origin.y+_lineGraph.frame.size.height-10, self.view.frame.size.width, 50)];
    eventlabel.backgroundColor=defineBlueColor;
    eventlabel.textAlignment=NSTextAlignmentCenter;
    eventlabel.textColor=[UIColor whiteColor];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY年 M月d日"];
    NSString *confromTimespStr = [formatter stringFromDate:[NSDate date]];
    NSInteger count=[[data objectForKey:confromTimespStr] count];
    eventlabel.text=[NSString stringWithFormat:@"%@: %d事件",confromTimespStr,count];
    [self.view addSubview:eventlabel];
}

-(void)disviewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getevent:(id)sender{
    NSNotification *tmp = (NSNotification *)sender;
    UIButton* button=(UIButton*)[tmp object];
    eventlabel.text=[NSString stringWithFormat:@"%@: %@事件",[seleArray objectAtIndex:button.tag],[coutArr objectAtIndex:button.tag]];
}

-(void)readData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    for (NSString* str in seleArray) {
        NSInteger coun=0;
        for (NSString* key in [data allKeys]) {
            if ([key isEqualToString:str]) {
               coun=[[data objectForKey:key] count];
            }
        }
        [coutArr addObject:[NSString stringWithFormat:@"%ld",(long)coun]];
    }

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return YES;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//	return UIInterfaceOrientationLandscapeLeft;
//}
//
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//	return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}

-(void)getdaydate{
  unsigned units=NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *mycal=[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now=[NSDate date];
    NSDateComponents *comp =[mycal components:units fromDate:now];
    NSInteger month=[comp month];
    NSInteger year =[comp year];
    NSInteger day=[comp day];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [gregorian components:NSWeekdayCalendarUnit fromDate:now];
    int daycount = [dateComps weekday] - 2;
    NSDate *weekdaybegin=[now addTimeInterval:-daycount*60*60*24];
    NSDate *weekdayend  =[now  addTimeInterval:(6-daycount)*60*60*24];
    NSDateFormatter *df1=[[NSDateFormatter alloc]init];
    NSLocale *mylocal=[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
    [df1 setLocale:mylocal];
    [df1 setDateFormat:@"YYYY-MM-d"];
    now=weekdaybegin;
    comp=[mycal components:units fromDate:now];
    month=[comp month];
    year =[comp year];
    day=[comp day];
   NSString* date1=[[NSString alloc]initWithFormat:@"%d-%02d-%02d",year,month,day];//所要求的周一的日期
    now=weekdayend;
    comp=[mycal components:units fromDate:now];
    month=[comp month];
    year =[comp year];
    day=[comp day];
   NSString* date2=[[NSString alloc]initWithFormat:@"%d-%02d-%02d",year,month,day];//所要求的周日的日期
    NSDate* date = [df1 dateFromString:date1];
    NSInteger time = [[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]] integerValue];

    for (int i=0; i<7; i++) {
        NSInteger temtime=time+(24*i*60*60);
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:temtime];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY年 M月d日"];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        [seleArray addObject:confromTimespStr];
        NSLog(@"%@",confromTimespStr);
    }
    
}

@end
