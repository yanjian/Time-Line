//
//  ReviewViewController.m
//  Go2
//
//  Created by IF on 15/3/31.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

//跟AllDateViewController中的定义是同一个  修改时注意
#define startTime @"start"
#define endTime   @"end"

typedef NS_ENUM(NSInteger, AllowAddTime) {
    AllowAddTime_NO=0,
    AllowAddTime_YES=1
};

typedef NS_ENUM(NSInteger, VoteAndFixTimeType) {
    VoteAndFixTimeType_Fix=1,
    VoteAndFixTimeType_Vote=2
};


#import "ReviewViewController.h"
#import "ActiveImageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "Friend.h"


static NSString * reviewCellID = @"ReviewCellID" ;
static NSString * value1ReviewCellID = @"value1ReviewCellID" ;
@interface ReviewViewController ()<ASIHTTPRequestDelegate>{
    ActiveImageTableViewCell * activeImgCell;
    UILabel * inviteCountLab;
    VoteAndFixTimeType voteAndFixTimeType;
    AllowAddTime  allowAddTime;
}

@end

@implementation ReviewViewController
@synthesize reviewTableview ;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Review" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToPurposeEventTimeView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_tick"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(saveEventData:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    voteAndFixTimeType = VoteAndFixTimeType_Vote;//默认投票
    allowAddTime = AllowAddTime_YES;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 160.f;
    }
    if(indexPath.section == 6 && indexPath.row == 0){
        return self.activeDataMode.activeCoordinate==nil?0.0f:160.f;
    }if (indexPath.section== 4 && indexPath.row == 0 ) {
        return self.activeDataMode.activeDesc==nil||[@"" isEqualToString:self.activeDataMode.activeDesc]? 0.0f : 64.f;
    }
    return 64.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 20.f ;
    }
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    inviteCountLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    inviteCountLab.text = [NSString stringWithFormat:@"%i Invites" , self.activeDataMode.activeFriendArr.count] ;
    inviteCountLab.textAlignment = NSTextAlignmentCenter ;
    inviteCountLab.backgroundColor = [UIColor whiteColor];
    inviteCountLab.textColor = [UIColor grayColor];
    return inviteCountLab;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (!activeImgCell) {
            activeImgCell =(ActiveImageTableViewCell *)[[[UINib nibWithNibName:@"ActiveImageTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
        activeImgCell.activeImag.image = self.activeDataMode.activeImg ;
        return activeImgCell ;
    }else{
        
        
        if (indexPath.section == 1||indexPath.section == 2 || indexPath.section == 3 ||indexPath.section == 4 || indexPath.section == 6 ){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reviewCellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reviewCellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                cell.textLabel.textAlignment = NSTextAlignmentCenter ;
            }
            if(indexPath.section == 1 && indexPath.row == 0){
                cell.textLabel.text = self.activeDataMode.activeTitle ;
            }else if (indexPath.section == 2 && indexPath.row == 0 ){
                NSInteger showCount = 0;  //要显示多少人数
                inviteCountLab.text = [NSString stringWithFormat:@"%d Invites", self.activeDataMode.activeFriendArr.count];
                for (UIView *childView in cell.contentView.subviews) {
                    [childView removeFromSuperview];
                }
                
                if (self.activeDataMode.activeFriendArr.count > 7) {
                    showCount = 7;
                }
                else {
                    showCount = self.activeDataMode.activeFriendArr.count;
                }
                
                
                UIScrollView * fivScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
                [fivScrollV setShowsHorizontalScrollIndicator:NO];
                [fivScrollV setShowsVerticalScrollIndicator:NO];
                
                fivScrollV.contentSize = CGSizeMake(48 * showCount, 0);
                UIView * memberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48 * showCount, 44)];
                [fivScrollV addSubview:memberView];
                
                for (int i = 0; i < showCount; i++) {
                    UIImageView * fiv =  [[UIImageView alloc] initWithFrame:CGRectMake((48*i)+(i==0?4:0), 3, 40, 40)];
                    fiv.layer.masksToBounds = YES ;
                    fiv.layer.cornerRadius = fiv.bounds.size.width/2;
                    id personInfo = self.activeDataMode.activeFriendArr[i];
                    if ([personInfo isKindOfClass:[Friend class]]) {
                        Friend *friend = (Friend *)personInfo;
                        NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:_urlStr];
                        [fiv sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    }
                    [memberView addSubview:fiv];
                }
                
                memberView.center = fivScrollV.center ;
                [cell addSubview:fivScrollV];
                
            } else if ( indexPath.section == 3  && indexPath.row == 0 ){
                 cell.textLabel.text = [NSString stringWithFormat:@"%i Time slots suggested",self.activeDataMode.activeVoteDate.count] ;
            }else if ( indexPath.section == 4  && indexPath.row == 0 ){
                 cell.textLabel.text = self.activeDataMode.activeDesc;
            }else if(indexPath.section == 6  && indexPath.row == 0){
                if (self.activeDataMode.activeCoordinate) {
                    MKMapView *vMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0,kScreen_Width, 160)];
                    vMap.delegate = self;
                    vMap.centerCoordinate = CLLocationCoordinate2DMake([[self.activeDataMode.activeCoordinate objectForKey:LATITUDE] doubleValue], [[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE] doubleValue]);
                    vMap.camera.altitude = 20;
                    vMap.showsBuildings = YES;
                    vMap.zoomEnabled = NO ;
                    vMap.scrollEnabled = NO ;
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = vMap.centerCoordinate;
                    annotation.title = self.activeDataMode.activeLocName;
                    [vMap addAnnotation:annotation];
                    [cell addSubview:vMap];
                }
            }
            return cell ;
        }else if (indexPath.section == 5 || indexPath.section  == 7 || indexPath.section  == 8 ||indexPath.section  == 9){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:value1ReviewCellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:value1ReviewCellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            }
            if(indexPath.section == 5 && indexPath.row == 0){
                cell.textLabel.text = @"Location:" ;
                if(self.activeDataMode.activeLocName){
                    cell.detailTextLabel.text = self.activeDataMode.activeLocName ;
                }else{
                    cell.detailTextLabel.text = @"No location information";
                }
            }if(indexPath.section == 7 && indexPath.row == 0){
                cell.textLabel.text = @"Due date to vote:" ;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE d MMM"];
                NSString *dateAndTime =  [dateFormatter stringFromDate:self.activeDataMode.activeDueVoteDate];
                cell.detailTextLabel.text = dateAndTime ;
            }if(indexPath.section == 8 && indexPath.row == 0){
                for (UIView *childView in cell.contentView.subviews) {
                    [childView removeFromSuperview];
                }
                
                UILabel * purporseLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-100, 64)];
                [purporseLab setNumberOfLines:2];
                purporseLab.text = @"   Participants can purpose\n   event time";
                UISwitch *purporseSwitch = [[UISwitch alloc] init];
                purporseSwitch.tag = 1 ;
                [purporseSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = purporseSwitch;
                [cell.contentView addSubview:purporseLab];
            }if(indexPath.section == 9 && indexPath.row == 0){
                for (UIView *childView in cell.contentView.subviews) {
                    [childView removeFromSuperview];
                }
                UILabel * purporseLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-100, 64)];
                purporseLab.text = @"   Participants can invite\n   their friends";
                [purporseLab setNumberOfLines:2];
                UISwitch *purporseSwitch = [[UISwitch alloc] init];
                purporseSwitch.tag = 2 ;
                [purporseSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = purporseSwitch;
                
                [cell.contentView addSubview:purporseLab];
            }
            return cell ;
        }
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(void)switchValueChange:(UISwitch *)sender {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)backToPurposeEventTimeView:(UIButton *) sender{
    [self.navigationController popViewControllerAnimated: YES];
}

-(void)saveEventData:(UIButton *)sender {
    if (self.isEdit) {
        NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];
        [activeDic setObject:self.activeDataMode.Id       forKey:@"id"];
         [activeDic setObject:self.activeEvent.create       forKey:@"create"];//创建者的id
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        if (self.activeDataMode.activeLocName && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:self.activeDataMode.activeLocName     forKey:@"location"];
        }
        if (self.activeDataMode.activeDesc && ![@"" isEqualToString:self.activeDataMode.activeDesc]) {
            [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"note"];
        }
        
        [activeDic setObject:@(voteAndFixTimeType)                 forKey:@"type"];
        [activeDic setObject:@(allowAddTime)                       forKey:@"addTime"];
        
        NSString *dueVoteDate = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:self.activeDataMode.activeDueVoteDate];
        [activeDic setObject:dueVoteDate forKey:@"voteEndTime"];
        
        NSMutableArray * tmpAddArr = [NSMutableArray array];//存放已经添加的人员
        //找到要添加的人员-----------------start----------------
        NSMutableArray * tmpAddingArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeFriendArr];//存放要添加的人员
        for (Friend *friend in self.activeDataMode.activeFriendArr) {//成员比较那些是添加的人员，那些是删除的人员
            for (NSDictionary *tmpDic in self.activeEvent.member) {
                NSString * uid = [tmpDic objectForKey:@"uid"];
                if ([friend.fid integerValue] == [uid integerValue]) {
                    [tmpAddingArr removeObject:friend];//存放要添加的人员中移除已经添加的人员
                    [tmpAddArr addObject:friend];
                    break;
                }
            }
        }
        NSMutableArray *addFriendIds = @[].mutableCopy ;
        for (Friend *friend in tmpAddingArr) {
            [addFriendIds addObject:friend.fid];
        }
       
        if(addFriendIds.count>0){
            [activeDic setObject:addFriendIds forKey:@"memberAdd"];
        }
        //-----------------------------end---------------------
        
        //找到要删除的人员----------------start------------------
        NSMutableArray * tmpDelingArr = [NSMutableArray arrayWithArray:self.activeEvent.member];//存放要添加的人员
        for (NSDictionary *tmpDic in self.activeEvent.member) {//成员比较那些是要铲除的人员
             NSString * uid = [tmpDic objectForKey:@"uid"];
            for (Friend *friend  in tmpAddArr) {
                if ([friend.fid integerValue] == [uid integerValue]) {
                    [tmpDelingArr removeObject:tmpDic];
                    break;
                }
            }
        }
        
        NSMutableArray *delFriendIds = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpDelingArr) {
            [delFriendIds addObject:[tmpDic objectForKey:@"uid"]];
        }
       
        if (delFriendIds.count > 0) {
             [activeDic setObject:delFriendIds forKey:@"memberDel"];
        }
        //-----------------------------end---------------------
        
        //找到新增的时间-------------------start----------------
        NSMutableArray * timeAddArr = [NSMutableArray array];//存放已经添加的人员
        NSMutableArray * tmpAddTimeArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeVoteDate];//存放要添加的人员
        for (NSDictionary  *timeDic in self.activeDataMode.activeVoteDate) {//成员比较那些是添加的人员，那些是删除的人员
            for (NSDictionary *tmpDic in self.activeEvent.time) {
                NSString * timeId = [tmpDic objectForKey:@"id"];
                if ([[timeDic objectForKey:@"id"] integerValue] == [timeId integerValue]) {
                    [tmpAddTimeArr removeObject:timeDic];//存放要添加的人员中移除已经添加的人员
                    [timeAddArr addObject:timeDic];
                    break;
                }
            }
        }
        NSMutableArray *addTimeArr = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpAddTimeArr) {
            NSDate *startDate = [tmpDic objectForKey:startTime];
            NSString *start = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:startDate];
            
            NSDate *endDate = [tmpDic objectForKey:endTime];
            NSString *end = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:endDate];

            [addTimeArr  addObject:@{@"startTime":start,@"endTime":end,@"allDay":@(0),@"finalTime":@(1)}];
        }
        [activeDic setObject:@(0) forKey:@"status"];
        if(addTimeArr.count>0){
            [activeDic setObject:addTimeArr forKey:@"timeAdd"];
        }
        //-----------------------------end----------------
        if (self.activeDataMode.activeCoordinate) {
            [activeDic setObject:[NSString stringWithFormat:@"%@;%@",[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]] forKey:@"coordinate"] ;
        }
        NSString * paramStr =  [activeDic JSONString];
        NSLog(@"%@",paramStr);
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:@{@"event":paramStr}.mutableCopy Url:anyTime_UpdateEvents Delegate:self Tag:anyTime_UpdateEvents_tag];
        [addActiveRequest startAsynchronous];

    }else{//新增event
        NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        if (self.activeDataMode.activeLocName && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:self.activeDataMode.activeLocName     forKey:@"location"];
        }
         if (self.activeDataMode.activeDesc && ![@"" isEqualToString:self.activeDataMode.activeDesc]) {
               [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"note"];
         }
        
        [activeDic setObject:@(voteAndFixTimeType)                 forKey:@"type"];
        [activeDic setObject:@(allowAddTime)                       forKey:@"addTime"];
        
        NSString *dueVoteDate = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:self.activeDataMode.activeDueVoteDate];
        [activeDic setObject:dueVoteDate forKey:@"veTime"];
        
        NSMutableArray *voteDateArr = @[].mutableCopy ;
        
        for (NSDictionary * dic in self.activeDataMode.activeVoteDate) {
            NSDate *startDate = [dic objectForKey:startTime];
            NSString *start = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:startDate];
           
            NSDate *endDate = [dic objectForKey:endTime];
            NSString *end = [self toStringFromDate:@"yyyy-MM-dd HH:mm:ss" formaterDate:endDate];
            [voteDateArr addObject:@{@"startTime":start,@"endTime":end,@"allDay":@(0)}];
        }
        
        [activeDic setObject:[voteDateArr JSONString] forKey:@"time"];
        
        NSMutableArray *inviteeArr = @[@{@"uid":[UserInfo currUserInfo].Id}].mutableCopy;
        for (Friend * friend in self.activeDataMode.activeFriendArr) {
            [inviteeArr addObject:@{@"uid":friend.fid}];
        }
        if (self.activeDataMode.activeCoordinate) {
            [activeDic setObject:[NSString stringWithFormat:@"%@;%@",[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]] forKey:@"coordinate"] ;
        }
       
        [activeDic setObject:[inviteeArr JSONString] forKey:@"member"];
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:anyTime_AddEvents Delegate:self Tag:anyTime_AddEvents_tag];
        [addActiveRequest startAsynchronous];
    }
    
}



- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *requestStr =  [request responseString];
    NSDictionary *dic = [requestStr objectFromJSONString];
    
    switch (request.tag) {
        case anyTime_AddEvents_tag:
        {
            NSString *statusCode = [dic objectForKey:@"statusCode"];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ([statusCode isEqualToString:@"1"]) {
                id tmpData = [dic objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    [MBProgressHUD showSuccess:@"Save Success"];
                    if (self.activeDataMode.activeImg) {
                        NSDictionary *tmpDic = (NSDictionary *)tmpData;
                        NSString *activeId = [tmpDic objectForKey:@"id"];
                        [self upLoadEventImage:activeId];
                    }else{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }
            else {
                [MBProgressHUD showError:[dic objectForKey:@"message"]];
            }
        }
        break;
        case anyTime_UpdateEvents_tag:{
            NSString *statusCode = [dic objectForKey:@"statusCode"];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ([statusCode isEqualToString:@"1"]) {
                id tmpData = [dic objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    [MBProgressHUD showSuccess:@"Operation Success"];
                    if (self.activeDataMode.activeImg) {
                        [self upLoadEventImage:self.activeDataMode.Id];
                    }else{
                         [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                }
            }
        }break;
            
        default:
            break;
    }
}

-(void)upLoadEventImage:(NSString *)eid {
        //上传活动图片
        NSURL *url = [NSURL URLWithString:[anyTime_EventAddPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        ASIFormDataRequest *uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
        [uploadImageRequest setRequestMethod:@"POST"];
        [uploadImageRequest setPostValue:eid forKey:@"eid"];
        NSData *data = UIImagePNGRepresentation(self.activeDataMode.activeImg);
        NSMutableData *imageData = [NSMutableData dataWithData:data];
        [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
        [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
        NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
        
        [uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
        [uploadImageRequest setTag:anyTime_EventAddPhoto_tag];
        __block ASIFormDataRequest *uploadRequest = uploadImageRequest;
        [uploadImageRequest setCompletionBlock: ^{
            NSString *responseStr = [uploadRequest responseString];
            NSLog(@"数据更新成功：%@", responseStr);
            id obj = [responseStr objectFromJSONString];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tmpDic = (NSDictionary *)obj;
                int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
                if (statusCode == 1) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }];
        [uploadImageRequest setFailedBlock: ^{
            NSLog(@"请求失败：%@", [uploadRequest responseString]);
            [MBProgressHUD showError:@"Please connect to the Internet"];
        }];
        [uploadImageRequest startAsynchronous];
}


#pragma marke - 格式化时间Date
- (NSString *)toStringFromDate:(NSString *)format formaterDate:(NSDate *) date {
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSString *loctime = [formatter stringFromDate:date];
    NSLog(@"%@", loctime);
    return loctime;
    
}
@end
