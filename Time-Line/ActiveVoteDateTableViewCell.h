//
//  ActiveVoteDateTableViewCell.h
//  Go2
//
//  Created by IF on 14/12/30.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义一个枚举：0表示对时间投票 1表示对选择内容投票
typedef NS_ENUM (NSInteger, VOTETIMEOROPION) {
	VOTETIME = 0,
	VOTEOPTION = 1
};
@protocol ActiveVoteDateTableViewCellDelegate;
@interface ActiveVoteDateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *showVoteCountLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn;
@property (weak, nonatomic) IBOutlet UIButton *showVoteTimeMember;
@property (weak, nonatomic) IBOutlet UILabel *optionContentLab;
@property (nonatomic, assign) VOTETIMEOROPION voteTimeOrOption;
@property (nonatomic, retain) id <ActiveVoteDateTableViewCellDelegate> delegate;
@property (nonatomic, retain) NSDictionary *paramDic;
@property (nonatomic, retain) NSArray *memberArr;
@end

@protocol ActiveVoteDateTableViewCellDelegate <NSObject>

@optional
- (void)activeVoteDateTableViewCell:(ActiveVoteDateTableViewCell *)selfCell isVoteTimeOrOption:(VOTETIMEOROPION)voteTimeOrOption ParamDictionnary:(NSDictionary *)paramDic isSelectForBtn:(BOOL)isSelect;

- (void)activeVoteDateTableViewCell:(ActiveVoteDateTableViewCell *)selfCell isVoteTimeOrOption:(VOTETIMEOROPION)voteTimeOrOption ParamArray:(NSArray *)paramArr;

@end
