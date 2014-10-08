//
//  DateDetailsViewController.m
//  Time-Line
//
//  Created by connor on 14-4-8.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "DateDetailsViewController.h"
#import "GoogleMapViewController.h"
@interface DateDetailsViewController ()

@property (nonatomic,strong)  NSDictionary *coordinateDic;//地图坐标
@end

@implementation DateDetailsViewController
@synthesize datedic,dateArr,event;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self initNavigationItem];

    // Do any additional setup after loading the view from its nib.
}

- (void)initNavigationItem
{
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 66)];
    rview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
    [self.view addSubview:rview];

    //    左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(20, 30, 21, 25);
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_ZVbutton];
    
    
    //    右边的按钮
    _YVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _YVbutton.frame = CGRectMake(280, 30, 21, 25);
    [_YVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_Edit.png"] forState:UIControlStateNormal];
    [_YVbutton addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_YVbutton];

    /* 导航栏标题 */
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(100, 20, 110, 30)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 110, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =event.eventTitle;
    [rview addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
}

-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString* cellId=@"cellIdentifierEven";
     UITableViewCell*  cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
         tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    if (indexPath.row==0) {
        UILabel* titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        titlelabel.textAlignment=NSTextAlignmentCenter;
        titlelabel.text=event.eventTitle;
        titlelabel.numberOfLines=2;
        titlelabel.lineBreakMode=NSLineBreakByWordWrapping;
        titlelabel.font=[UIFont boldSystemFontOfSize:17.0f];
        titlelabel.textColor=[UIColor blackColor];
        
        
        
        UILabel* startlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 25)];
        startlabel.textAlignment=NSTextAlignmentCenter;
        NSString* start_title=event.startDate;
        startlabel.text=[self dateStringWithFormaterString:start_title];

        
        UILabel* endlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, 25)];
        endlabel.textAlignment=NSTextAlignmentCenter;
        NSString* end_titles=event.endDate;
        endlabel.text=[self dateStringWithFormaterString:end_titles];

        UILabel* notelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 50)];
        notelabel.textAlignment=NSTextAlignmentCenter;
        notelabel.text=event.note;
        [cell.contentView addSubview:titlelabel];
        [cell.contentView addSubview:startlabel];
        [cell.contentView addSubview:endlabel];
        [cell.contentView addSubview:notelabel];
        
    }
    
    NSString* str=event.location;
    if (str.length>0) {
        if (indexPath.row==1) {
            NSArray *coorArr=nil;
            if (![event.coordinate isEqualToString:@""]&&event.coordinate) {
                NSLog(@"%@",event.coordinate)
               coorArr= [event.coordinate componentsSeparatedByString:@","];
            }
            if ([coorArr count]>0) {
                NSLog(@"%@",coorArr)
                self.coordinateDic=@{LATITUDE: [coorArr objectAtIndex:0],LONGITUDE:[coorArr objectAtIndex:1]};
            }
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            label.text=str;
            label.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
    }
    return cell;
}


-(NSString *)dateStringWithFormaterString:(NSString *) formateString
{
    NSDateFormatter *formatters =[[NSDateFormatter alloc] init];
    [formatters setDateFormat:@"YYYY年 M月dd日HH:mm"];
    NSDate* dates=[formatters dateFromString:formateString];
    NSString* weakStrs=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:dates];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
    NSArray* arrays=[formateString componentsSeparatedByString:@"/"];
    return [NSString stringWithFormat:@"%@  %@/%@ %@",weakStrs,[arrays objectAtIndex:2],[arrays objectAtIndex:1],[arrays objectAtIndex:3]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString* str=event.location;
    if (str.length>0) {
          return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 175;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==1) {
//        MapViewController* map=[[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
//        [self.navigationController pushViewController:map animated:YES];
        GoogleMapViewController *map=[[GoogleMapViewController alloc] init];
        [map setCoordinateDictionary:self.coordinateDic];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:map animated:YES];
    }

}

-(void)editEvent{
    
    AddEventViewController* viewcon=[[AddEventViewController alloc]initWithNibName:@"AddEventViewController" bundle:nil];
    viewcon.state=@"edit";
    viewcon.event=event;
    viewcon.dateArr=dateArr.mutableCopy;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:viewcon animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)GetHtmlFromUrl:(NSString *)urlStr
{
    ///获取html数据
    return [[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
}

@end
