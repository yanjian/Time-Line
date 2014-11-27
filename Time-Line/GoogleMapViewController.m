//
//  GoogleMapViewController.m
//  Time-Line
//
//  Created by IF on 14-9-16.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "GoogleMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MMLocationManager.h"
@interface GoogleMapViewController ()

@property (nonatomic ,retain)   NSDictionary *coordinateDic;
@property (strong,nonatomic) GMSMapView *mapView_;
@property (strong,nonatomic) GMSCameraPosition *camera;

@end

@implementation GoogleMapViewController

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
    //self.navigationController.navigationBar.barTintColor = blueColor;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =@"Location Details";

    self.navigationItem.titleView=titleLabel;
}


-(void)disviewcontroller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"====%f",[[self.coordinateDic objectForKey:LATITUDE] doubleValue]);
     _camera = [GMSCameraPosition cameraWithLatitude:[[self.coordinateDic objectForKey:LATITUDE] doubleValue]
                                                            longitude:[[self.coordinateDic objectForKey:LONGITUDE] doubleValue]
                                                                 zoom:9];
    self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    self.mapView_.myLocationEnabled = NO;
    self.view = self.mapView_;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = _camera.target;
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView_;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCoordinateDictionary:(NSDictionary *) coordinateDictionary{
    if (coordinateDictionary) {
        self.coordinateDic=[NSDictionary dictionaryWithDictionary:coordinateDictionary];
    }else{//为nil就得到自己所在位置
        __block NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [[MMLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
            [dic setObject:[NSNumber numberWithDouble:locationCorrrdinate.latitude] forKey:LATITUDE];
            [dic setObject:[NSNumber numberWithDouble:locationCorrrdinate.longitude] forKey:LONGITUDE];
        }];
        self.coordinateDic=dic;
    }
}
@end
