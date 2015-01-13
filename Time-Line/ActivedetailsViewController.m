//
//  ActivedetailsViewController.m
//  Time-Line
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ActivedetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "ActiveVoteDateTableViewCell.h"
#import "FriendInformationView.h"
#import "CLDay.h"
#import "MemberListViewController.h"
#import "UserInfo.h"
#import "ViewController.h"
#import "AnyEvent.h"
#import "ActiveFooterView.h"
#import "AddActiveViewController.h"
#import "UserInfo.h"

#define footerCellHeight_AddYes  90
#define footerCellHeight_AddNo   42
#define voteDateCellHeight 50

#define voteContentTableViewCellH 44

@interface ActivedetailsViewController ()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,ActiveVoteDateTableViewCellDelegate,settimeDay,ActiveFooterViewDelegate>{
    UIImageView * _activeImgView;//活动图
    UILabel * _titleLab;//显示活动标题
    UIView  * _joinAndNoJoinView;
    NSArray * _joinAndNoJoinArr;
    
    UITableView  * _voteDateTableView;
    int _timeCount;
    NSArray * memberArr;
    
    UITableView  * _voteContentTableView;
    int _contentCount;
    NSString *_joinStatus;
    NSInteger _addTime;
    
    int _voteContentTotal;

    UILabel * _locationLab;
    UILabel * _noteLab;
    
    NSMutableArray * _timeArr;
    int varHeight;
    int _enableAddCount;
    
    NSMutableArray * _voteOptionArr;
    int addRowCount ;
}

@property (nonatomic,retain) UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *MemberInviteeView;
@property (weak, nonatomic) IBOutlet UILabel *inviteeTitleLab;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *showMemberVIew;

@end

@implementation ActivedetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    memberArr = self.activeEvent.member;
    
    _timeArr = [NSMutableArray arrayWithArray:self.activeEvent.time];
    _voteOptionArr = [NSMutableArray arrayWithArray:self.activeEvent.evList];
    
    UserInfo * userInfo = [UserInfo currUserInfo];
    for (NSDictionary *dic in memberArr) {
       NSString * uid = [dic objectForKey:@"uid"];
       
        if([userInfo.Id isEqualToString:[NSString stringWithFormat:@"%@",uid]] ){
            int join = [[dic objectForKey:@"join"] integerValue];
            if (join == 1){
                _joinStatus=@"1";//参加
            }else{
                _joinStatus=@"0";//bu参加
            }
        }
    }
    
    _addTime = [self.activeEvent.addTime integerValue];//1表示用户可用添加时间。0 表示用户不能添加时间
    
    [self createNavView];
    [self createCellOfTableWithActiveImage];
    [self createJoinActiveBtn];
    [self createVoteDateView];
    [self createVoteContentView];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _titleLab.font = [UIFont boldSystemFontOfSize:15.0f];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    
    _locationLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _locationLab.font = [UIFont boldSystemFontOfSize:15.0f];
    _locationLab.textAlignment = NSTextAlignmentCenter;
    
    _noteLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _noteLab.font = [UIFont boldSystemFontOfSize:15.0f];
    _noteLab.textAlignment = NSTextAlignmentCenter;
    
    CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-naviHigth);
    self.view.frame=frame;
    self.tableView=[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view  addSubview:self.tableView];
}

#pragma mark -初始化导航视图
-(void)createNavView{
    // 导航
    self.navigationController.navigationBar.barTintColor =blueColor;
    
    //左边的按钮
    
    UIButton * zvbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    zvbutton.frame = CGRectMake(15, 30, 21, 25);
    zvbutton.backgroundColor = [UIColor clearColor];
    [zvbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    zvbutton.tag = 1;
    [zvbutton addTarget:self action:@selector(eventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:zvbutton];
    
    NSString * createId = [NSString stringWithFormat:@"%@",[self.activeEvent create]] ;
    NSString * currId = [[UserInfo currUserInfo] Id];
    if ([createId isEqualToString:currId]) {//这里如果当前用户是创建者就显示编辑按钮
        UIButton * rbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        rbutton.frame = CGRectMake(280, 30, 21, 25);
        rbutton.backgroundColor = [UIColor clearColor];
        [rbutton setBackgroundImage:[UIImage imageNamed:@"Icon_Edit"] forState:UIControlStateNormal];
        rbutton.tag=2;
        [rbutton addTarget:self action:@selector(eventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rbutton];
    }
    
    //中间icon
    UIView * midView = [[UIView alloc] initWithFrame:CGRectMake(88, 20, kScreen_Width-2*88, 44)];
    [midView setBackgroundColor:[UIColor clearColor]];
    UIImageView  *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(45,0, 50, 44)];
    [imgView setImage:[UIImage imageNamed:@"open_default"]];
    [imgView setBackgroundColor:[UIColor clearColor]];
    [midView addSubview:imgView];
    self.navigationItem.titleView=midView;
    
}


#pragma mark -创建表格中的活动图片
-(void)createCellOfTableWithActiveImage{
    _activeImgView =  [[UIImageView alloc] initWithFrame: CGRectMake(0, 1,self.view.frame.size.width, 160) ];
}


#pragma mark -创建参加或不参加按钮
-(void)createJoinActiveBtn{
    _joinAndNoJoinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width ,84)];
    
    UIButton * joinBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 84)];
    [joinBtn setTitle:@"Joining" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [joinBtn setTag:3];
    [joinBtn setTitleColor:purple forState:UIControlStateSelected];
    
    [joinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * noJoinBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 84)];
    [noJoinBtn setTitle:@"Not Joining" forState:UIControlStateNormal];
    [noJoinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [noJoinBtn setTitleColor:purple forState:UIControlStateSelected];
    [noJoinBtn setTag:4];
    [noJoinBtn addTarget:self action:@selector(eventTouchUpInsideJoin:) forControlEvents:UIControlEventTouchUpInside];
    if ([_joinStatus isEqualToString:@"1"]) {//表示参加
        [joinBtn setTitleColor:purple forState:UIControlStateNormal];
    }else{
        [noJoinBtn setTitleColor:purple forState:UIControlStateNormal];
    }
     _joinAndNoJoinArr = [NSArray arrayWithObjects:joinBtn,noJoinBtn, nil];
    
    [_joinAndNoJoinView addSubview:joinBtn];
    [_joinAndNoJoinView addSubview:noJoinBtn];
}

#pragma mark -创建投票时间视图
-(void)createVoteDateView{
    
     _timeCount = _timeArr.count==0?1:_timeArr.count;
    varHeight = (_addTime==1?footerCellHeight_AddYes:footerCellHeight_AddNo);
    _voteDateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteDateCellHeight*_timeCount+varHeight) style:UITableViewStylePlain];
    _voteDateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _voteDateTableView.bounces=NO;
    _voteDateTableView.showsVerticalScrollIndicator = NO;
    _voteDateTableView.dataSource = self;
    _voteDateTableView.delegate = self;
    
       //voteTableView 的底部视图
    if (_addTime ==1) {//表示可用添加时间
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width
                                                                          , footerCellHeight_AddYes)];
        UIButton *addTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addTimeBtn.frame=CGRectMake(20, 10, footerView.frame.size.width-2*20, 40);
        [addTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        addTimeBtn.layer.borderWidth = 0.5f;
        addTimeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [addTimeBtn setTitle:@"➕    Add a date..." forState:UIControlStateNormal];
        [addTimeBtn addTarget:self action:@selector(addMutableDateVote) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addTimeBtn];
        UILabel * allowLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, kScreen_Width-2*50, 32)];
        allowLab.text = [NSString stringWithFormat:@"%@",self.activeEvent.voteEndTime];
        UILabel * deadLineLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 70, 32)];
        deadLineLab.text = @"Deadline ";
        [footerView addSubview:allowLab];
        [footerView addSubview:deadLineLab];
        _voteDateTableView.tableFooterView = footerView;
    }else{
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width
                                                                          , footerCellHeight_AddNo)];
        UILabel * allowLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, kScreen_Width-2*50, 32)];
        allowLab.text = [NSString stringWithFormat:@"%@",self.activeEvent.voteEndTime];
        UILabel * deadLineLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 70, 32)];
        deadLineLab.text = @"Deadline ";
        [footerView addSubview:allowLab];
        [footerView addSubview:deadLineLab];
        _voteDateTableView.tableFooterView = footerView;
    }
}

#pragma mark -创建投票内容视图
-(void)createVoteContentView{
    addRowCount = 0;
    _contentCount = _voteOptionArr.count==0?1:_voteOptionArr.count;
    _enableAddCount =0;
    if (_voteOptionArr.count>0) {
        for (NSDictionary *voteContentDic in _voteOptionArr) {
            NSArray * optionList= [voteContentDic objectForKey:@"optionList"];
             _voteContentTotal+=optionList.count;
             int enableAdd = [[voteContentDic objectForKey:@"enableAdd"] intValue];//1表示可用添加选项
            if(enableAdd == 1){
                _enableAddCount +=1;
            }
        }
    }
    
    
    _voteContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteContentTableViewCellH*(_contentCount+_voteContentTotal+_enableAddCount)) style:UITableViewStyleGrouped];
    _voteContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _voteContentTableView.bounces=NO;
    _voteContentTableView.showsVerticalScrollIndicator = NO;
    _voteContentTableView.dataSource = self;
    _voteContentTableView.delegate = self;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_voteDateTableView  == tableView) {
       
        return _timeCount;
    }else if (_voteContentTableView==tableView){
        return _contentCount;
    } else{
        return 8;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_voteContentTableView==tableView) {
        NSArray * voteContentArr=nil;
        if (_voteOptionArr.count>0) {
            voteContentArr = [_voteOptionArr[section] objectForKey:@"optionList"];
        }
        return voteContentArr==nil?0:voteContentArr.count;
    }else
     return 1;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _voteDateTableView){
        return voteDateCellHeight;
    }else if(_voteContentTableView == tableView){
        return voteContentTableViewCellH;
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 162.f;
            }
        }else if (indexPath.section==1){
            if (indexPath.row == 0) {
                return  60.f;
            }
        } else if(indexPath.section == 3){
            if (indexPath.row ==0 ) {
                return voteDateCellHeight*_timeCount+(_addTime==1?footerCellHeight_AddYes:footerCellHeight_AddNo);
            }
            
        }else if (indexPath.section == 4){
            if (indexPath.row == 0) {
                return 120.f;
            }
        }else if (indexPath.section == 5){
            if (indexPath.row == 0) {
                return voteContentTableViewCellH*(_contentCount+_voteContentTotal+_enableAddCount +addRowCount);
            }
        }else if(indexPath.section == 6){
            if (indexPath.row == 0) {
                return 60.f;
            }
        }else if(indexPath.section == 7){
            if (indexPath.row == 0) {
                return 60.f;
            }
        }

        return 84.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_voteContentTableView == tableView){
        return voteContentTableViewCellH;
    }else{
        return 0.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(_voteContentTableView == tableView){
        return _enableAddCount ==0?0.0000000001f:voteContentTableViewCellH;//哎！牟知怎么搞的先就这样搞吧
    }else {
        return 0.0f;
    }
    
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView ;
    if(_voteContentTableView == tableView){
        if (_voteOptionArr.count>0) {
            headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteContentTableViewCellH)];
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteContentTableViewCellH)];
            titleLab.text=  [_voteOptionArr[section] objectForKey:@"title"];
            titleLab.textAlignment = NSTextAlignmentCenter;
            [titleLab setBackgroundColor:[UIColor whiteColor]];
            [headView addSubview:titleLab];

        }
        
    }
    return headView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    ActiveFooterView *footerView ;
    if(_voteContentTableView == tableView){
        if (_voteOptionArr.count>0) {
            int enableAdd = [[_voteOptionArr[section] objectForKey:@"enableAdd"] intValue];//1表示可用添加选项
            if(enableAdd == 1 && _voteOptionArr.count > 0){
                footerView = [[ActiveFooterView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteContentTableViewCellH)];
                footerView.voteOptionDic = _voteOptionArr[section];
                footerView.selectSection = section;
                footerView.delegate = self ;
            }
        }
    }
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _voteDateTableView) {
        static NSString *voteId = @"voteDateId";
        ActiveVoteDateTableViewCell *voteDateCell = [tableView dequeueReusableCellWithIdentifier:voteId];
        if (!voteDateCell) {
            voteDateCell =(ActiveVoteDateTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:@"ActiveVoteDateTableViewCell" owner:self options:nil] lastObject];
        }
        
        if( _timeArr.count>0){
            NSDictionary * timeDic =  _timeArr[indexPath.section];
            if([_joinStatus isEqualToString:@"0"]){
                voteDateCell.voteBtn.hidden = YES;
            }else{
                voteDateCell.voteBtn.hidden = NO;
            }
            
            voteDateCell.voteTimeOrOption = VOTETIME;
            voteDateCell.voteBtn.tag = indexPath.section;
            voteDateCell.delegate = self;
            voteDateCell.paramDic = timeDic;
            
            if (timeDic) {
                NSString *startTime = [timeDic objectForKey:@"startTime"];
                NSString *endTime = [timeDic objectForKey:@"endTime"];
                if (startTime) {
                    NSRange strPoint = [startTime rangeOfString:@"."];
                    if (strPoint.location != NSNotFound) {
                        startTime = [startTime substringToIndex:strPoint.location];
                    }
                }
                if (endTime) {
                    NSRange strPoint = [endTime rangeOfString:@"."];
                    if (strPoint.location != NSNotFound) {
                        endTime = [endTime substringToIndex:strPoint.location];
                    }
                }
                NSMutableArray *memberArray = [NSMutableArray array];
                int _voteTimeCount=0;//对时间投票的人数
                if (self.activeEvent.etList) {//用户投票的时间
                    NSString * currUserId = [UserInfo currUserInfo].Id;
                    int timeId = [[timeDic objectForKey:@"id"] intValue];//得到时间的id
                    for (NSDictionary *dic in self.activeEvent.etList) {
                       int tid = [[dic objectForKey:@"tid"] intValue];//用户投票时间的id
                       int uid = [[dic objectForKey:@"uid"] intValue];//投票时间的用户id
                        if(timeId == tid){
                            _voteTimeCount++;
                            for (NSDictionary *memberDic in self.activeEvent.member) {
                               int tmpUid = [[memberDic objectForKey:@"uid"] intValue];
                                if (uid == tmpUid) {
                                    [memberArray addObject:memberDic];
                                }
                                if (tmpUid == [currUserId intValue] ) {
                                    voteDateCell.voteBtn.selected =YES;
                                }
                            }
                        }
                    }
                }
                voteDateCell.memberArr = memberArray;
                
                voteDateCell.showVoteCountLab.text = [NSString stringWithFormat:@"%i",_voteTimeCount];
                
                NSDate * startDate = [[PublicMethodsViewController getPublicMethods]  stringToDate:startTime];
                NSDate * endDate = [[PublicMethodsViewController getPublicMethods]  stringToDate:endTime];
                
                CLDay *now=[[CLDay alloc] initWithDate:startDate];
                NSString *startTimeStr = [[PublicMethodsViewController getPublicMethods] shortTimeFromDate: startDate];
                
                NSString *endTimeStr = [[PublicMethodsViewController getPublicMethods] shortTimeFromDate: endDate];
                
                 voteDateCell.dateLab.text = [now weekDayMotch];
                 voteDateCell.timeLab.text = [NSString stringWithFormat:@"%@ → %@",startTimeStr,endTimeStr] ;
            }
        }
        return voteDateCell;
    }else if (tableView == _voteContentTableView){
        static NSString *voteId = @"voteContentId";
        ActiveVoteDateTableViewCell *voteContentCell = [tableView dequeueReusableCellWithIdentifier:voteId];
        if (!voteContentCell) {
            voteContentCell = (ActiveVoteDateTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:@"ActiveVoteDateTableViewCell" owner:self options:nil] lastObject];
        }
        NSArray *optionArr = [_voteOptionArr[indexPath.section] objectForKey:@"optionList"];
        NSDictionary *optionValDic = optionArr[indexPath.row];
        
        if([_joinStatus isEqualToString:@"0"]){
            voteContentCell.voteBtn.hidden = YES;
        }else{
            voteContentCell.voteBtn.hidden = NO;
        }
        voteContentCell.voteTimeOrOption = VOTEOPTION;
        voteContentCell.voteBtn.tag = [[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row] integerValue] ;
        voteContentCell.delegate = self;
        voteContentCell.paramDic = optionValDic;
        voteContentCell.optionContentLab.text = [optionValDic objectForKey:@"option"];
        int evid = [[optionValDic objectForKey:@"evid"] intValue];
        int optionId = [[optionValDic objectForKey:@"id"] intValue];
        
        NSArray * optionVoteArr = [_voteOptionArr[indexPath.section] objectForKey:@"optionVoteList"];
        NSString * currUserId = [UserInfo currUserInfo].Id ;
        int voteCount = 0;
         NSMutableArray *memberArray = [NSMutableArray array];
        for (NSDictionary * tmpDic in optionVoteArr) {
           
            int userId = [[tmpDic objectForKey:@"uid"] intValue];
            int evidTmp = [[tmpDic objectForKey:@"evid"] intValue];
            int optionIdTmp = [[tmpDic objectForKey:@"evoid"] intValue];
            if (evid == evidTmp && optionId == optionIdTmp) {
                voteCount ++ ;
                if ([currUserId intValue] == userId) {
                    voteContentCell.voteBtn.selected = YES;
                }
                for (NSDictionary *memberDic in self.activeEvent.member) {
                    int tmpUid = [[memberDic objectForKey:@"uid"] intValue];
                    if (userId == tmpUid) {
                        [memberArray addObject:memberDic];
                    }
                }
            }
        }
        voteContentCell.memberArr = memberArray;
        voteContentCell.showVoteCountLab.text = [NSString stringWithFormat:@"%i",voteCount];
        return voteContentCell;
    } else {
        
        static NSString * detailID = @"detailCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:detailID];
        if (!cell) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailID];
        }
        //取消选中行的样式
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        //清除contentView中的所有视图
        NSArray *subviews = [[NSArray alloc]initWithArray:cell.contentView.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
        if (indexPath.section==0)
        {
            if (indexPath.row==0)
            {
                NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,self.activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@",_urlStr);
                NSURL *url=[NSURL URLWithString:_urlStr];
                [_activeImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018"]];
                
                [cell.contentView addSubview:_activeImgView];
            }
        }else if (indexPath.section == 1){
            if (indexPath.row == 0) {
                _titleLab.text = self.activeEvent.title;
                [cell.contentView addSubview:_titleLab ];
            }
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_joinAndNoJoinView];
            }
        }else if (indexPath.section == 3){
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_voteDateTableView];
            }
        }else if (indexPath.section ==4 ){
            if (indexPath.row == 0) {
                int joinCount =0;
                int memberCount = memberArr.count;
                if(memberCount>5){
                    self.moreBtn.hidden = NO;
                }else{
                    self.moreBtn.hidden = YES;
                }
                for (int i=0; i<memberCount; i++) {
                    FriendInformationView * fiv =  [FriendInformationView initFriendInfoView];
                    fiv.frame=CGRectMake(62*i, 10, 50, 80);
                    
                    NSDictionary *memberDic = [memberArr objectAtIndex:i];
                    
                    fiv.friendNameLab.text=[memberDic objectForKey:@"name"];
                    NSString *imgPath = [memberDic objectForKey:@"imgBig"];
                    if (imgPath) {
                        imgPath=[imgPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    }
                     int join = [[memberDic objectForKey:@"join"] integerValue];//参加的人：1表示已经参加，2表示不参加
                    if (join == 1) {//参加的人数
                        joinCount++;
                    }
                    NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,imgPath]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *url = [NSURL URLWithString:_urlStr];
                    [fiv.friendHeadimg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    [self.showMemberVIew addSubview:fiv];
                }
                self.inviteeTitleLab.text= [NSString stringWithFormat:@"%d Invitees ( %i  joining )",memberArr.count,joinCount];
                return self.MemberInviteeView;
            }
        }else if (indexPath.section == 5){
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_voteContentTableView];
            }
        }else if(indexPath.section == 6){
            if (indexPath.row == 0) {
                _locationLab.text = self.activeEvent.location;
                [cell.contentView addSubview:_locationLab];
            }
        }else if(indexPath.section == 7){
            if (indexPath.row == 0) {
                _noteLab.text = self.activeEvent.note;
                [cell.contentView addSubview:_noteLab];
            }
        }
        return cell;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)showMoreMember:(UIButton *)sender {
    MemberListViewController * memberListVc = [[MemberListViewController alloc] init];
    memberListVc.memberArr = memberArr;
    [self presentViewController:memberListVc animated:YES completion:nil];
}

#pragma  mark -导航栏中的返回或编辑事件
-(void)eventTouchUpInside:(UIButton *) sender{
    if (sender.tag == 1){
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelActivedetailsViewController:)]) {
            [self.delegate cancelActivedetailsViewController:self];
        }
    }else if (sender.tag == 2){
        AddActiveViewController * aVc = [[AddActiveViewController alloc] init];
        aVc.isEdit = YES;
        aVc.activeEventMode = self.activeEvent;
        [self.navigationController pushViewController:aVc animated:YES];
    }
}



#pragma mark -添加投票时间
-(void)addMutableDateVote{
    ViewController* controler=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    AnyEvent * eventData=[AnyEvent MR_createEntity];
    eventData.eventTitle=_titleLab.text;
    NSDate * startDate = [[NSDate date] dateByAddingTimeInterval:5*60];
    eventData.startDate= [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
    NSDate * endDate =[startDate dateByAddingTimeInterval:1*60*60];
    eventData.endDate= [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
    eventData.isAllDay=@(0);//全天事件 标记
    [controler addEventViewControler:self anyEvent:eventData];
    controler.detelegate=self;
    [self.navigationController pushViewController:controler animated:YES ];
}

#pragma mark -用与操作用户是对时间投票了还是对内容选项投票了的操作的代理
-(void)activeVoteDateTableViewCell:(ActiveVoteDateTableViewCell *) selfCell isVoteTimeOrOption:(VOTETIMEOROPION) voteTimeOrOption ParamDictionnary:(NSDictionary *) paramDic isSelectForBtn:(BOOL) isSelect{
   int tmpCount = [selfCell.showVoteCountLab.text intValue];
    if (voteTimeOrOption == VOTETIME) {
        int type = 2;
        if (isSelect) {
            type =1;
            tmpCount+=1;
        }else{
             tmpCount-=1;
        }
        ASIHTTPRequest *voteTimeRequest = [t_Network httpPostValue:@{@"eid":[paramDic objectForKey:@"eid"],@"tid":[paramDic objectForKey:@"id"],@"type":@(type)}.mutableCopy Url:anyTime_VoteTimeForEvent Delegate:self Tag:anyTime_VoteTimeForEvent_tag];
        [voteTimeRequest startAsynchronous];
        
         NSLog(@"%i",tmpCount+1) ;
        selfCell.showVoteCountLab.text = [NSString stringWithFormat:@"%i" ,tmpCount ];
        
    }else if (voteTimeOrOption == VOTEOPTION){
        if (isSelect) {
            tmpCount+=1;
            
            ASIHTTPRequest *voteOptionRequest = [t_Network httpGet:@{@"evid":[paramDic objectForKey:@"evid"],@"evoid":[paramDic objectForKey:@"id"]}.mutableCopy Url:anyTime_VoteEventOtherOption Delegate:self Tag:anyTime_VoteEventOtherOption_tag];
            [voteOptionRequest startAsynchronous];
        }else{
            tmpCount-=1;
            ASIHTTPRequest *voteOptionRequest = [t_Network httpGet:@{@"evid":[paramDic objectForKey:@"evid"],@"evoid":[paramDic objectForKey:@"id"]}.mutableCopy Url:anyTime_VoteEventOtherOptionCancel Delegate:self Tag:anyTime_VoteEventOtherOptionCancel_tag];
            [voteOptionRequest startAsynchronous];
        }
        selfCell.showVoteCountLab.text = [NSString stringWithFormat:@"%i" ,tmpCount ];
    }
}

#pragma mark -用与操作用户是对时间投票了或对内容选项投票了的人员查看代理
-(void)activeVoteDateTableViewCell:(ActiveVoteDateTableViewCell *) selfCell isVoteTimeOrOption:(VOTETIMEOROPION) voteTimeOrOption ParamArray:(NSArray *) paramArr{
    MemberListViewController * memberListVc = [[MemberListViewController alloc] init];
    memberListVc.memberArr = paramArr ;
    [self presentViewController:memberListVc animated:YES completion:nil];
}


#pragma mark -时间控制器的代理
- (void)getstarttime:(NSString*)start getendtime:(NSString*)end isAllDay:(BOOL) isAll{
   NSString *startStr = [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"yyyy-MM-dd HH:mm" dateString:start];
    NSString *endStr =  [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"yyyy-MM-dd HH:mm" dateString:end];
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    
    [tmpDic setObject:startStr forKey:@"start"];
    [tmpDic setObject:endStr forKey:@"end"];
    if(isAll){
        [tmpDic setObject:@(1) forKey:@"allDay"];
    }else{
        [tmpDic setObject:@(0) forKey:@"allDay"];
    }
    NSArray *tmpArr = [NSArray arrayWithObjects:tmpDic, nil];
    
    NSString *jsonStr = [tmpArr JSONString];
    ASIHTTPRequest *addTimeRequest = [t_Network httpPostValue:@{@"eid":self.activeEvent.Id,@"time":jsonStr}.mutableCopy Url:anyTime_AddEventTime Delegate:self Tag:anyTime_AddEventTime_tag ];
    
    [addTimeRequest startAsynchronous];

}


#pragma mark -参加或不参加按钮事件
-(void)eventTouchUpInsideJoin:(UIButton *) sender{
    for (UIButton *btn in _joinAndNoJoinArr) {
        btn.selected = NO;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    }
    sender.selected = YES;
    int joinType=0;
    if (sender.tag==3) {
        _joinStatus=@"1";//表示参加
        joinType=1;
    }else if (sender.tag==4){
        _joinStatus=@"0";//表示不参加
        joinType =2;//不参加
    }
    
    ASIHTTPRequest *joinRequest = [t_Network httpGet:@{@"eid":_activeEvent.Id,@"join":@(joinType)}.mutableCopy Url:anyTime_JoinEvent Delegate:self Tag:anyTime_JoinEvent_tag];
    [joinRequest startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseStr = [request responseString];
    NSDictionary *tmpDic = [responseStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_JoinEvent_tag:
            {
                NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    [_voteDateTableView reloadData];
                    [_voteContentTableView reloadData];
                    [_tableView reloadData];
                    NSLog(@"成功！");
                }
            }
            break;
        case anyTime_VoteTimeForEvent_tag:
            {
              NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    
                }

            }
            break;
        case anyTime_VoteEventOtherOption_tag:{
            NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                
            }

        }
            break;
        case anyTime_VoteEventOtherOptionCancel_tag:{
            NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                
            }
        }
            break;
        case anyTime_AddEventTime_tag:{
            NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                NSArray * tmpArr = [tmpDic objectForKey:@"data"];
                if (tmpArr&&tmpArr.count>0) {
                     _timeArr =[NSMutableArray arrayWithArray:tmpArr]   ;
                }
                _timeCount = _timeArr.count;
                _voteDateTableView.frame = CGRectMake(0, 0, kScreen_Width, voteDateCellHeight*_timeCount+varHeight);
                
                [_voteDateTableView reloadData];
                [_tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}

-(void)activeFooterView:(ActiveFooterView *) footerView returnValue:(NSArray *) returnArr selectSection:(NSInteger) section{
    
     NSArray *optionArr = [_voteOptionArr[section] objectForKey:@"optionList"];
    addRowCount += returnArr.count - optionArr.count;
    NSMutableDictionary * optionDic = [NSMutableDictionary dictionaryWithDictionary:_voteOptionArr[section]];
    [optionDic removeObjectForKey:@"optionList"];
    [optionDic setObject:returnArr forKey:@"optionList"];
    
    [_voteOptionArr removeObject:_voteOptionArr[section]];
    [_voteOptionArr insertObject:optionDic atIndex:section];
    _voteContentTableView.frame = CGRectMake(0, 0, kScreen_Width, voteContentTableViewCellH*(_contentCount+_voteContentTotal+addRowCount+_enableAddCount));

    [_voteContentTableView reloadData];
    [_tableView reloadData];
}
@end
