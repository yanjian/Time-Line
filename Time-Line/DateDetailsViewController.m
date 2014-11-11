//
//  DateDetailsViewController.m
//  Time-Line
//
//  Created by connor on 14-4-8.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "DateDetailsViewController.h"
#import "GoogleMapViewController.h"
#import "Calendar.h"
#import "CircleDrawView.h"
@interface DateDetailsViewController (){
   UIImageView *addressIcon;
}

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
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self initNavigationItem];

    // Do any additional setup after loading the view from its nib.
}

- (void)initNavigationItem
{
    
    
    
    self.navigationController.navigationBar.barTintColor=blueColor;
    
    _detaileTableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-64) style:UITableViewStyleGrouped];
    _detaileTableview.delegate=self;
    _detaileTableview.dataSource=self;
    [self.view addSubview:_detaileTableview];
    
   
    
//    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
//    rview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
//    [self.view addSubview:rview];
    
    //    左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(20, 30, 21, 25);
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:_ZVbutton];
//    [rview addSubview:_ZVbutton];
    
    
    
    //    右边的按钮
    _YVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _YVbutton.frame = CGRectMake(280, 30, 21, 25);
    [_YVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_Edit.png"] forState:UIControlStateNormal];
    [_YVbutton addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:_YVbutton];

    /* 导航栏标题 */
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =event.eventTitle;
 
    UILabel* accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 200, 12)];
    accountLabel.textAlignment = NSTextAlignmentCenter;
    accountLabel.font = [UIFont boldSystemFontOfSize:12];
    accountLabel.textColor = [UIColor whiteColor];
    NSString *summarystr=[event.calendar summary];
    accountLabel.text =summarystr ;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize size = [summarystr boundingRectWithSize:CGSizeMake(200, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    CircleDrawView *cd=[[CircleDrawView alloc] initWithFrame:CGRectMake(accountLabel.frame.size.width/2-size.width/2-25,2, 20, 10)];
    cd.hexString=[event.calendar backgroundColor];
    [accountLabel addSubview:cd];
    [titleView addSubview:titleLabel];
    [titleView addSubview:accountLabel];
    self.navigationItem.titleView = titleView ;
    
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
    if (indexPath.section==0&& indexPath.row==0) {
         NSString *intervalTime=[[PublicMethodsViewController getPublicMethods]  timeDifference:event.endDate getStrart:event.startDate];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(30, 65, 40, 40);
        [btn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:12.f];
        [btn setTitle:intervalTime forState:UIControlStateNormal];
        [cell.contentView addSubview:btn];
        UILabel* titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        titlelabel.textAlignment=NSTextAlignmentCenter;
        titlelabel.text=event.eventTitle;
        titlelabel.numberOfLines=2;
        titlelabel.font=[UIFont boldSystemFontOfSize:17.0f];
        titlelabel.textColor=[UIColor blackColor];
        
        
        
        UILabel* startlabel=[[UILabel alloc]initWithFrame:CGRectMake(65, 60, self.view.frame.size.width-170, 25)];
        startlabel.textAlignment=NSTextAlignmentRight;
        NSString* start_title=event.startDate;
        NSArray *startArr=[self dateStringWithFormaterString:start_title];
        startlabel.text=[NSString stringWithFormat:@"%@  %@/%@",startArr[4],startArr[2],startArr[1]];

        UILabel* timeStartlabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 60, 60, 25)];
        timeStartlabel.textAlignment=NSTextAlignmentCenter;
        timeStartlabel.text=startArr[3];
        
        
        UILabel* endlabel=[[UILabel alloc]initWithFrame:CGRectMake(65, 85, self.view.frame.size.width-170, 25)];
        endlabel.textAlignment=NSTextAlignmentRight;
        NSString* end_titles=event.endDate;
        NSArray *endArr=[self dateStringWithFormaterString:end_titles];
        endlabel.text=[NSString stringWithFormat:@"%@  %@/%@",endArr[4],endArr[2],endArr[1]];
        
        UILabel* timeEndlabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70,85, 60, 25)];
        timeEndlabel.textAlignment=NSTextAlignmentCenter;
        timeEndlabel.text=startArr[3];
        timeEndlabel.text=endArr[3];
        
        [cell.contentView addSubview:titlelabel];
        [cell.contentView addSubview:startlabel];
        [cell.contentView addSubview:timeStartlabel];
        [cell.contentView addSubview:endlabel];
        [cell.contentView addSubview:timeEndlabel];
    }else if(indexPath.section==1&&indexPath.row==0){
        NSString* str=event.location;
        NSString *noteStr=event.note;
        if ((str.length>0&&noteStr.length<=0)||(str.length>0&&noteStr.length>0)) {
            if (indexPath.row==0) {
                NSArray *coorArr=nil;
                if (![event.coordinate isEqualToString:@""]&&event.coordinate) {
                    NSLog(@"%@",event.coordinate);
                    coorArr= [event.coordinate componentsSeparatedByString:@","];
                }
                if ([coorArr count]>0) {
                    NSLog(@"%@",coorArr);
                    self.coordinateDic=@{LATITUDE: [coorArr objectAtIndex:0],LONGITUDE:[coorArr objectAtIndex:1]};
                }
                addressIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adress_Icon"]];
                NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
                CGSize size = [str boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                addressIcon.frame=CGRectMake( (self.view.bounds.size.width/2-size.width/2)-23,15, 10, 15);
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
                label.text=str;
                label.textAlignment=NSTextAlignmentCenter;
                [cell.contentView addSubview:label];
                [cell.contentView addSubview:addressIcon];
            }
        }else if (str.length<=0&&noteStr.length>0){
            UILabel* notelabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 50)];
            notelabel.textAlignment=NSTextAlignmentCenter;
            notelabel.text=event.note;
            [cell.contentView addSubview:notelabel];
        }
    }else if(indexPath.section==2&&indexPath.row==0){
        if (event.note) {
            UILabel* notelabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 50)];
            notelabel.textAlignment=NSTextAlignmentCenter;
            notelabel.text=event.note;
            [cell.contentView addSubview:notelabel];
        }
    }
    return cell;
}


-(NSMutableArray *)dateStringWithFormaterString:(NSString *) formateString
{
    NSDateFormatter *formatters =[[NSDateFormatter alloc] init];
    [formatters setDateFormat:@"YYYY年 M月dd日HH:mm"];
    NSDate* dates=[formatters dateFromString:formateString];
    NSString* weakStrs=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:dates];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
    formateString=[formateString stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
    NSMutableArray* arrays=[[formateString componentsSeparatedByString:@"/"] mutableCopy];
    [arrays insertObject:weakStrs atIndex:arrays.count];
    return arrays;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"%@=====%@",event.location,event.note);
    if (![@"" isEqualToString:event.location]) {
        if (![@"" isEqualToString:event.note]) {
            return 3;
        }else{
            return 2;
        }
        
    }else{
        if (![@"" isEqualToString:event.note]) {
            return 2;
        }else{
            return 1;
        }
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&& indexPath.row==0) {
        return 130;
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
    //self.navigationController.navigationBarHidden = NO;
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
