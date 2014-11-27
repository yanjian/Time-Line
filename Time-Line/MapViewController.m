//
//  MapViewController.m
//  Time-Line
//
//  Created by connor on 14-4-21.
//  Copyright (c) 2014年 connor. All rights reserved.
//
////起点
//double startLat = 34.7712;
//double startLng = 113.7240;



double startLat = 22.5391148085;
double startLng = 114.1135483445;

////终点
double endLat = 34.7524;
double endLng = 113.6657;
#import "MapViewController.h"
#import <MapKit/MKMapItem.h>
@interface MapViewController ()

@end

@implementation MapViewController

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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 66)];
    
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    

    
    

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    leftBtn.backgroundColor = [UIColor yellowColor];
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:leftBtn];
    
    
    
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(100, 20, 140, 40)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =@"地图";
    [titleView addSubview:titleLabel];
    [view addSubview:titleView];
    
    
//    self.navigationItem.titleView = titleView;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    UIButton *rightBtn_add = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [rightBtn_add setFrame:CGRectMake(280, 20, 20, 20)];
    [rightBtn_add addTarget:self action:@selector(Mapevent) forControlEvents:UIControlEventTouchUpInside];
    //[view addSubview:rightBtn_add];
   // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_add];


    UIWebView* webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height)];
    NSString *travelType = @"driving";
    //NSString *urlStr = [NSString stringWithFormat:@"http://www.zdoz.net/api/daohang.aspx?TravelType=%@&startLat=%f&startLng=%f&endLat=%f&endLng=%f",travelType,startLat,startLng,endLat,endLng];
    
    
     NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com"];
    
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    [self.view addSubview:webview];
    // Do any additional setup after loading the view from its nib.
}

-(void)Mapevent{
    CLLocationCoordinate2D to;
    //要去的目标经纬度
    to.latitude = endLat;
    to.longitude = endLng;
    CLLocationCoordinate2D from;
    //要去的目标经纬度
    from.latitude = startLat;
    from.longitude = startLng;
//     MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];//调用自带地图（定位）
    MKMapItem*  currentLocation=[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
    //显示目的地坐标。画路线
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
    toLocation.name = @"开始";
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                  
                                                             forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    
}

-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
