//
//  EventTimeTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "EventTimeTableViewCell.h"
#import "ActiveTimeVoteMode.h"


@implementation EventTimeTableViewCell

- (void)awakeFromNib {
    self.eventTimebgView.layer.cornerRadius  = 2;
    //    self.subContentView.layer.masksToBounds = YES ;
    self.eventTimebgView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.eventTimebgView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.eventTimebgView.layer.shadowOpacity = 0.8 ;
    self.eventTimebgView.layer.shadowRadius  = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



-(void)setCreateHost:(BOOL)createHost{
    _createHost = createHost ;
    
    self.eventTime.text = @"Event Time ?";
    self.eventTimeStatus.text = @"Status: Voting" ;
    if (_createHost) {
        self.showDesc.text = @"To be confirmed" ;
        
        [self.chooseAvailibilityBtn setTitle:@"  Close poll" forState:UIControlStateNormal];
        
         self.chooseAvailibilityBtn.tag = 1 ;
        [self.chooseAvailibilityBtn addTarget:self action:@selector(chooseAvailibilityAndPoll:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.showDesc.text  = @"choose a time that works for you" ;
        
        [self.chooseAvailibilityBtn setTitle:@"  Choose your availbility" forState:UIControlStateNormal];
        
        self.chooseAvailibilityBtn.tag = 2 ;
        [self.chooseAvailibilityBtn addTarget:self action:@selector(chooseAvailibilityAndPoll:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - 创建者是否确定时间
/**
 * 
 *  创建者是否确定时间
 *  @param timeConfirmed 布尔值 yes 确定
 */
-(void)setTimeConfirmed:(BOOL)timeConfirmed{
    _timeConfirmed = timeConfirmed ;
    
    if ( _timeConfirmed ) { // -- 投票的时间已经确定 --
        NSString * startStr = [self voteEDMDateStringFromVoteDateString:self.activeVoteTime];
        NSDictionary * timeDic = [self voteHHMMDictionaryFromVoteTimeString:self.activeVoteTime];
        NSString *timeStr = [[PublicMethodsViewController getPublicMethods] timeDifference:self.activeVoteTime.end getStrart:self.activeVoteTime.start formmtterStyle:@"YYYY-MM-dd HH:mm:ss"];
        if (self.isCreateHost) {// 创建活动者 -- 显示的界面信息 --
            [self.eventTimeStatus setTextColor:RGBCOLOR(42, 191, 76)];
            [self.eventTimeStatus setText:@"Status: Confirmed"];
            self.eventTime.text = startStr ;
            self.showDesc.text  = [NSString stringWithFormat:@"%@ -- %@ (%@)",[timeDic objectForKey:@"start"],[timeDic objectForKey:@"end"],timeStr] ;
            
            
            self.eventIconImg.image = [UIImage imageNamed:@"Card2_ic-reopenPoll"] ;
            [self.chooseAvailibilityBtn setTitle:@"  Reopen poll" forState:UIControlStateNormal];
            
            self.chooseAvailibilityBtn.tag = 3 ;
            [self.chooseAvailibilityBtn addTarget:self action:@selector(chooseAvailibilityAndPoll:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [self.eventTimeStatus setTextColor:RGBCOLOR(42, 191, 76)];
            [self.eventTimeStatus setText:@"Status: Confirmed"];
            self.eventTime.text = startStr ;
            self.showDesc.text  = [NSString stringWithFormat:@"%@ -- %@ (%@)",[timeDic objectForKey:@"start"],[timeDic objectForKey:@"end"],timeStr] ;
        }
    }else{
        if (!self.isCreateHost) {// 非创建活动者 -- 显示的界面信息 --
            self.showDesc.text = @"Wait for host to close the poll" ;
            [self.eventTimeStatus setTextColor:RGBCOLOR(254, 113, 38)];
            [self.eventTimeStatus setText:@"Status: Voted"];
            
            self.eventIconImg.image = [UIImage imageNamed:@"Card2_ic-chooseTime"] ;
            [self.chooseAvailibilityBtn setTitle:@"  Change your availbility" forState:UIControlStateNormal];
            self.chooseAvailibilityBtn.tag = 2 ;
            [self.chooseAvailibilityBtn addTarget:self action:@selector(chooseAvailibilityAndPoll:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


-(void)chooseAvailibilityAndPoll:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{
            [self.delegate closePoll:self];
        } break;
            
        case 2:{
            [self.delegate chooseYourAvailability:self];
        } break;
        
        case 3:{
            [self.delegate reopenPoll:self];
        } break;
            
        default:
            break;
    }
}

#pragma mark - 将一个时间字符串转换成另外一个时间字符串（YYYY-MM-dd HH:mm:ss--->EEE, d MMM）
-(NSString *)voteEDMDateStringFromVoteDateString:(ActiveTimeVoteMode *) voteTimeModel{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    NSDate * start = [dateFormatter dateFromString:voteTimeModel.start];
//  NSDate * end   = [dateFormatter dateFromString:voteTimeModel.end];

    [dateFormatter setDateFormat:@"EEE, d MMMM"];
   
    return  [dateFormatter stringFromDate:start];
}

/**
 *  将时间格式化成小时制（如 05:10 AM）
 *
 *  @param voteTimeModel
 *
 *  @return 返回时间字典
 */
-(NSDictionary *)voteHHMMDictionaryFromVoteTimeString:(ActiveTimeVoteMode *) voteTimeModel{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    NSDate * start = [dateFormatter dateFromString:voteTimeModel.start];
    NSDate * end   = [dateFormatter dateFromString:voteTimeModel.end];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    return @{@"start":[dateFormatter stringFromDate:start],@"end":[dateFormatter stringFromDate:end]};
}

@end
