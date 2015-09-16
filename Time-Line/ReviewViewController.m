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
#import "UIColor+HexString.h"

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
@property (nonatomic,strong) MKMapView *vMap;
@property (nonatomic,strong) UIScrollView * fivScrollV;
@property (nonatomic,strong) UILabel * purporseLab;
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
    self.reviewTableview.separatorStyle = UITableViewCellSeparatorStyleNone ;
    
    voteAndFixTimeType = VoteAndFixTimeType_Vote;//默认投票
    
    if (self.isEdit) {
        if ( [self.activeEvent.canProposeTime boolValue] ) {
            allowAddTime = AllowAddTime_YES;
        }else{
            allowAddTime = AllowAddTime_NO ;
        }
    } else {
        allowAddTime = AllowAddTime_YES;
    }
}


-(MKMapView *)vMap{
    if (!_vMap){
        _vMap = [[MKMapView alloc] initWithFrame:CGRectMake(10, 0,kScreen_Width-20, 160)];
        _vMap.delegate = self;
        _vMap.camera.altitude = 20;
        _vMap.showsBuildings = YES;
        _vMap.zoomEnabled = NO ;
        _vMap.scrollEnabled = NO ;
    }
    return _vMap ;
}

-(UIScrollView *)fivScrollV{
    if (!_fivScrollV) {
         _fivScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
        [_fivScrollV setShowsHorizontalScrollIndicator:NO];
        [_fivScrollV setShowsVerticalScrollIndicator:NO];
    }
    return _fivScrollV;
}

-(UILabel *)purporseLab{
    if (!_purporseLab) {
         _purporseLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-100, 64)];
        [_purporseLab setNumberOfLines:2];
         _purporseLab.text = @"   Participants can purpose\n   event time";
    }
    return _purporseLab ;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 8;
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
        
        [self addCellSeparator:160 cell:activeImgCell];
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
                
                [self addCellSeparator:64 cell:cell];
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

                
                self.fivScrollV.contentSize = CGSizeMake(48 * showCount, 0);
                UIView * memberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48 * showCount, 44)];
                [self.fivScrollV addSubview:memberView];
                
                for (int i = 0; i < showCount; i++) {
                    UIImageView * fiv =  [[UIImageView alloc] initWithFrame:CGRectMake((48*i)+(i==0?4:0), 3, 40, 40)];
                    fiv.layer.masksToBounds = YES ;
                    fiv.layer.cornerRadius = fiv.bounds.size.width/2;
                    id personInfo = self.activeDataMode.activeFriendArr[i];
                    if ([personInfo isKindOfClass:[Friend class]]) {
                        Friend *friend = (Friend *)personInfo;
                        NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, friend.thumbnail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:_urlStr];
                        [fiv sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    }
                    [memberView addSubview:fiv];
                }
                
                memberView.center = self.fivScrollV.center ;
                [cell addSubview:self.fivScrollV];
                
                [self addCellSeparator:64 cell:cell];
            }else if ( indexPath.section == 3  && indexPath.row == 0 ){
                 cell.textLabel.text = [NSString stringWithFormat:@"%i Time slots suggested",self.activeDataMode.activeVoteDate.count] ;
                [self addCellSeparator:64 cell:cell];
            }else if ( indexPath.section == 4  && indexPath.row == 0 ){
                 cell.textLabel.text = self.activeDataMode.activeDesc;
                
                [self addCellSeparator:64 cell:cell];
            }else if(indexPath.section == 6  && indexPath.row == 0){
                if (self.activeDataMode.activeCoordinate) {
                    self.vMap.centerCoordinate = CLLocationCoordinate2DMake([[self.activeDataMode.activeCoordinate objectForKey:LATITUDE] doubleValue], [[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE] doubleValue]);
                   
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = self.vMap.centerCoordinate;
                    annotation.title = self.activeDataMode.activeLocName;
                    [self.vMap addAnnotation:annotation];
                    [cell addSubview:self.vMap];
                    
                    [self addCellSeparator:160 cell:cell];
                }
            }
            return cell ;
        }else if (indexPath.section == 5 || indexPath.section  == 6 || indexPath.section  == 7 ||indexPath.section  == 8){
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
                
                [self addCellSeparator:64 cell:cell];
            }else if(indexPath.section == 7 && indexPath.row == 0){
                for (UIView *childView in cell.contentView.subviews) {
                    [childView removeFromSuperview];
                }
                
                UISwitch *purporseSwitch = [[UISwitch alloc] init];
                purporseSwitch.tag = 1 ;
                purporseSwitch.on  =  allowAddTime == AllowAddTime_YES ? YES : NO ;
                [purporseSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = purporseSwitch;
                [cell.contentView addSubview:self.purporseLab];
               
                [self addCellSeparator:64 cell:cell];
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
    if (sender.on) {
        allowAddTime = AllowAddTime_YES ;
        sender.on = YES ;
    }else {
         allowAddTime = AllowAddTime_NO ;
         sender.on = NO ;
    }
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
        [activeDic setObject:self.activeDataMode.Id                forKey:@"id"];
        [activeDic setObject:self.activeEvent.createId             forKey:@"create"];//创建者的id
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        if (self.activeDataMode.activeLocName && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:[@{@"location":self.activeDataMode.activeLocName==nil?@"":self.activeDataMode.activeLocName,
                                    @"latitude":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],
                                    @"longitude":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE],@"description":@""
                                    } JSONString]
                          forKey:@"location"];

        }
        if (self.activeDataMode.activeDesc &&  ! [@"" isEqualToString:self.activeDataMode.activeDesc]) {
            [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"description"];
        }
        
        [activeDic setObject:@(allowAddTime)                       forKey:@"canProposeTime"];
        
        NSMutableArray * tmpAddArr = [NSMutableArray array];//存放已经添加的人员
        //找到要添加的人员-----------------start----------------
        NSMutableArray * tmpAddingArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeFriendArr];//存放要添加的人员
        for (Friend *friend in self.activeDataMode.activeFriendArr) {//成员比较那些是添加的人员，那些是删除的人员
            for (NSDictionary *tmpDic in self.activeEvent.invitees) {
                NSString * uid = [tmpDic objectForKey:@"uid"];
                if ( [ friend.Id isEqualToString:uid ] ) {
                    [tmpAddingArr removeObject:friend];//存放要添加的人员中移除已经添加的人员
                    [tmpAddArr addObject:friend];
                    break;
                }
            }
        }
        NSMutableArray *addFriendIds = @[].mutableCopy ;
        for (Friend *friend in tmpAddingArr) {
            [addFriendIds addObject:@{@"uid":friend.Id}];
        }
       
        if(addFriendIds.count>0){
            [activeDic setObject:[addFriendIds JSONString] forKey:@"invitees"];
        }
        //-----------------------------end---------------------
        
        //找到要删除的人员----------------start------------------
        NSMutableArray * tmpDelingArr = [NSMutableArray arrayWithArray:self.activeEvent.invitees];//存放要添加的人员
        for (NSDictionary *tmpDic in self.activeEvent.invitees) {//成员比较那些是要铲除的人员
             NSString * uid = [tmpDic objectForKey:@"uid"];
            for (Friend *friend  in tmpAddArr) {
                if ( [ friend.Id isEqualToString:uid ] ) {
                    [tmpDelingArr removeObject:tmpDic];
                    break;
                }
            }
        }
        
        NSMutableArray *delFriendIds = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpDelingArr) {
            NSString * fid = [tmpDic objectForKey:@"uid"] ;
            if (![fid isEqualToString:[UserInfo currUserInfo].Id]) {//排除自己
                [delFriendIds addObject:@{ @"uid":fid }];
            }
        }
       
        if (delFriendIds.count > 0) {
             [activeDic setObject:[delFriendIds JSONString] forKey:@"deleteInvitees"];
        }
        //-----------------------------end---------------------
        
        //找到新增的时间-------------------start----------------
        NSMutableArray * timeAddArr = [NSMutableArray array];
        NSMutableArray * tmpAddTimeArr = [NSMutableArray arrayWithArray:self.activeDataMode.activeVoteDate];
        
        for (NSDictionary  *timeDic in self.activeDataMode.activeVoteDate) {
            for (NSDictionary *tmpDic in self.activeEvent.proposeTimes) {
                NSString * timeId = [tmpDic objectForKey:@"id"];
                if ( [timeId isEqualToString: [timeDic objectForKey:@"id"]] ) {
                    [tmpAddTimeArr removeObject:timeDic];
                    [timeAddArr addObject:timeDic];
                    break;
                }
            }
        }
        NSMutableArray *addTimeArr = @[].mutableCopy ;
        for (NSDictionary *tmpDic in tmpAddTimeArr) {
            NSDate *startDate = [tmpDic objectForKey:startTime];
            NSString *start = [self getUTCFormateLocalDate:startDate];
            
            NSDate *endDate = [tmpDic objectForKey:endTime];
            NSString *end = [self getUTCFormateLocalDate:endDate];
           [addTimeArr  addObject:@{@"start":start,@"end":end,@"isAllday":@(0) }];
        }
        [activeDic setObject:@(0) forKey:@"status"];
        if(addTimeArr.count>0){
            [activeDic setObject:[addTimeArr JSONString]forKey:@"proposeTimes"];
        }
        //-----------------------------end----------------
        
        NSMutableArray * tmpDeleteTimeArr = [NSMutableArray arrayWithArray:self.activeEvent.proposeTimes];
        for (NSDictionary  *timeDic in self.activeEvent.proposeTimes) {
            for (NSDictionary *tmpDic in self.activeDataMode.activeVoteDate) {
                NSString * timeId = [tmpDic objectForKey:@"id"];
                if ( [timeId isEqualToString: [timeDic objectForKey:@"id"]] ) {
                    [tmpDeleteTimeArr removeObject:timeDic];
                    break;
                }
            }
        }
        
        if(tmpDeleteTimeArr.count>0){
            NSMutableArray *delTimeIds = @[].mutableCopy ;
            for (NSDictionary *tmpDic in tmpDeleteTimeArr) {
                NSString * tid = [tmpDic objectForKey:@"id"] ;
                [delTimeIds addObject:@{ @"id":tid }];
            }
            
            [activeDic setObject:[delTimeIds JSONString]forKey:@"deleteTimes"];
        }

        
        if (self.activeDataMode.activeCoordinate) {
            [activeDic setObject:[NSString stringWithFormat:@"%@;%@",[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]] forKey:@"coordinate"] ;
        }
        [activeDic setObject:@"updateSocial" forKey:@"method"];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:Go2_socials Delegate:self Tag:Go2_UpdateEvents_tag];
        [addActiveRequest startAsynchronous];

    }else{//新增event
        NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];
        [activeDic setObject:self.activeDataMode.activeTitle       forKey:@"title"];
        
        //location={"location":"地址"，"latitude":"纬度","longitude":"经度","description":"地址详细描述"}
        if (self.activeDataMode.activeLocName!=nil && ![@"" isEqualToString:self.activeDataMode.activeLocName]) {
            [activeDic setObject:[@{@"location":self.activeDataMode.activeLocName==nil?@"":self.activeDataMode.activeLocName,
                                    @"latitude":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LATITUDE],
                                    @"longitude":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE]==nil?@"":[self.activeDataMode.activeCoordinate objectForKey:LONGITUDE],@"description":@""
                                    } JSONString]
                          forKey:@"location"];
        }
       
        if (self.activeDataMode.activeDesc && ![@"" isEqualToString:self.activeDataMode.activeDesc]) {
               [activeDic setObject:self.activeDataMode.activeDesc        forKey:@"description"];
         }

        [activeDic setObject:@(allowAddTime)          forKey:@"canProposeTime"];
           
        NSMutableArray *voteDateArr = @[].mutableCopy ;
        
        for (NSDictionary * dic in self.activeDataMode.activeVoteDate) {
            NSDate *startDate = [dic objectForKey:startTime];
            NSString *start = [self getUTCFormateLocalDate:startDate];
           
            NSDate *endDate = [dic objectForKey:endTime];
            NSString *end = [self getUTCFormateLocalDate:endDate];
            [voteDateArr addObject:@{@"start":start,@"end":end,@"isAllday":@(0)}];
        }
        
        [activeDic setObject:[voteDateArr JSONString] forKey:@"proposeTimes"];
        
        NSMutableArray *inviteeArr = @[@{@"uid":[UserInfo currUserInfo].Id}].mutableCopy;
        for (Friend * friend in self.activeDataMode.activeFriendArr) {
            [inviteeArr addObject:@{@"uid":friend.Id}];
        }
        
        [activeDic setObject:[inviteeArr JSONString] forKey:@"invitees"];
        [activeDic setObject:@"add" forKey:@"method"];
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:Go2_socials Delegate:self Tag:Go2_addSocials_Tag];
        [addActiveRequest startAsynchronous];
    }
    
}



- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *requestStr =  [request responseString];
    NSDictionary *dic = [requestStr objectFromJSONString];
    
    switch (request.tag) {
        case Go2_addSocials_Tag:
        {
            int statusCode = [[dic objectForKey:@"statusCode"] intValue];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ( statusCode == 1 ) {
                id tmpData = [dic objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    if (self.activeDataMode.activeImg) {
                        NSDictionary *tmpDic = (NSDictionary *)tmpData;
                        NSString *activeId = [tmpDic objectForKey:@"id"];
                        [self upLoadEventImage:activeId];
                    }else{
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        [MBProgressHUD showSuccess:@"Operation Success"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }else {
                [MBProgressHUD showError:[dic objectForKey:@"message"]];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        }
        break;
        case Go2_UpdateEvents_tag:{
            int statusCode = [[dic objectForKey:@"statusCode"] intValue];
            NSError *error = [request error];
            if (error) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [MBProgressHUD showError:@"save fail"];
                return;
            }
            if ( statusCode  == 1 ) {
                id tmpData = [dic objectForKey:@"data"];
                if ([tmpData isKindOfClass:[NSDictionary class]]) {
                    if (self.activeDataMode.activeImg) {
                        [self upLoadEventImage:self.activeDataMode.Id];
                    }else{
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        [MBProgressHUD showSuccess:@"Operation Success"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }
        }break;
            
        default:
            break;
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request{
     [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

-(void)upLoadEventImage:(NSString *)eid {
        //上传活动图片
        NSURL * url = [NSURL URLWithString:[Go2_UploadSocialFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        ASIFormDataRequest * uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
        [uploadImageRequest setRequestMethod:@"POST"];
        [uploadImageRequest setPostValue:eid    forKey:@"eid"];
        [uploadImageRequest setPostValue:@"img" forKey:@"type"];
        NSData *data = UIImagePNGRepresentation(self.activeDataMode.activeImg);
        NSMutableData *imageData = [NSMutableData dataWithData:data];
        [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
        [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
        NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
        
        [uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
        [uploadImageRequest setTag:Go2_UploadSocialFile_Tag];
        __block ASIFormDataRequest *uploadRequest = uploadImageRequest;
        [uploadImageRequest setCompletionBlock: ^{
            NSString *responseStr = [uploadRequest responseString];
            NSLog(@"数据更新成功：%@", responseStr);
            id obj = [responseStr objectFromJSONString];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tmpDic = (NSDictionary *)obj;
                int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
                if ( statusCode == 1 ) {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [MBProgressHUD showSuccess:@"Operation Success"];
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

-(NSString *)getUTCFormateLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

//添加分割线
-(void)addCellSeparator:(CGFloat) LocaltionY cell:(UITableViewCell *) cell{
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, LocaltionY-1, cell.frame.size.width -20, 1)];
    separator.backgroundColor = [UIColor colorWithHexString:@"eeecec"];
    [cell.contentView addSubview:separator];
}
@end
