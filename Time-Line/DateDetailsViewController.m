//
//  DateDetailsViewController.m
//  Time-Line
//
//  Created by connor on 14-4-8.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "DateDetailsViewController.h"
#import "MapViewController.h"
@interface DateDetailsViewController ()

@end

@implementation DateDetailsViewController
@synthesize datedic;
@synthesize dateArr;
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
    
//    UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
//    headview.backgroundColor=[UIColor grayColor];
//    UIImageView* imageview=[[UIImageView alloc]initWithFrame:headview.frame];
//    if ([[datedic objectForKey:@"url"] isEqualToString:@"photo.png"]) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"photo.png"];
//        imageview.image=[UIImage imageWithContentsOfFile:plistPath];
//    }else{
//    imageview.image=[UIImage imageNamed:[datedic objectForKey:@"url"]];
//    }
//    [headview addSubview:imageview];
//    _detaileTableview.tableHeaderView=headview;
    
    
    
    
    
    
    

    // Do any additional setup after loading the view from its nib.
}

- (void)initNavigationItem
{
//    self.navigationController.navigationBar.barTintColor = blueColor;
    
    /* 导航栏左
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 15, 20)];
    leftBtn.backgroundColor = [UIColor redColor];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    UIButton *rightBtn_add = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn_add setBackgroundImage:[UIImage imageNamed:@"Icon_Edit.png"] forState:UIControlStateNormal];
    [rightBtn_add setFrame:CGRectMake(35, 10, 20, 20)];
    [rightBtn_add addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_add];
    */
    
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 66)];
    rview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
    [self.view addSubview:rview];

    //    左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(20, 30, 21, 25);
    //    _ZVbutton.backgroundColor = [UIColor redColor];
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_ZVbutton];
    
    
    //    右边的按钮
    _YVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _YVbutton.frame = CGRectMake(280, 30, 21, 25);
    //_YVbutton.backgroundColor = [UIColor redColor];
    [_YVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_Edit.png"] forState:UIControlStateNormal];
    [_YVbutton addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_YVbutton];

    
    
    
    /* 导航栏标题 */
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(100, 20, 110, 30)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 110, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text =[datedic objectForKey:@"title"];
    [rview addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
}

-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString* cellId=@"cell";
     UITableViewCell*  cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
         tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    if (indexPath.row==0) {
        UILabel* titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        titlelabel.textAlignment=NSTextAlignmentCenter;
        titlelabel.text=[datedic objectForKey:@"title"];
        titlelabel.numberOfLines=2;
        titlelabel.lineBreakMode=NSLineBreakByWordWrapping;
        titlelabel.font=[UIFont boldSystemFontOfSize:17.0f];
        titlelabel.textColor=[UIColor blackColor];
        
        
        
        UILabel* startlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 25)];
        startlabel.textAlignment=NSTextAlignmentCenter;
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日HH:mm"];
        NSString* table_title=[datedic objectForKey:@"start"];
        NSDate* date=[formatter dateFromString:table_title];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        
        table_title=[table_title stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[table_title componentsSeparatedByString:@"/"];
        
        startlabel.text=[NSString stringWithFormat:@"%@  %@/%@ %@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1],[array objectAtIndex:3]];

        UILabel* endlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, 25)];
        endlabel.textAlignment=NSTextAlignmentCenter;
        NSDateFormatter *formatters =[[NSDateFormatter alloc] init];
        [formatters setDateFormat:@"YYYY年 M月dd日HH:mm"];
        NSString* table_titles=[datedic objectForKey:@"end"];
        NSDate* dates=[formatters dateFromString:table_titles
                       ];
        NSString* weakStrs=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:dates];
        table_titles=[table_titles stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        table_titles=[table_titles stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        table_titles=[table_titles stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* arrays=[table_titles componentsSeparatedByString:@"/"];
        endlabel.text=[NSString stringWithFormat:@"%@  %@/%@ %@",weakStrs,[arrays objectAtIndex:2],[arrays objectAtIndex:1],[arrays objectAtIndex:3]];

        UILabel* notelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 50)];
        notelabel.textAlignment=NSTextAlignmentCenter;
        notelabel.text=[datedic objectForKey:@"note"];
        [cell.contentView addSubview:titlelabel];
        [cell.contentView addSubview:startlabel];
        [cell.contentView addSubview:endlabel];
        [cell.contentView addSubview:notelabel];
        
    }
    NSString* str=[datedic objectForKey:@"loc"];
    if (str.length>0) {
        if (indexPath.row==1) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            label.text=[datedic objectForKey:@"loc"];
            label.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }

    }
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString* str=[datedic objectForKey:@"loc"];
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
        MapViewController* map=[[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
        [self.navigationController pushViewController:map animated:YES];
    }

}

-(void)editEvent{
    
    AddEventViewController* viewcon=[[AddEventViewController alloc]initWithNibName:@"AddEventViewController" bundle:nil];
    viewcon.state=@"edit";
    viewcon.dateDic=datedic;
    viewcon.dateArr=dateArr;
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
