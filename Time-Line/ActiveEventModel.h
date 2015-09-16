//
//  ActiveEventModel.h
//  Go2
//
//  Created by IF on 15/8/12.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface ActiveEventModel : BaseMode

@property (nonatomic,copy)   NSString  * Id ;
@property (nonatomic,copy)   NSString  * createId;
@property (nonatomic,copy)   NSString  * title;
@property (nonatomic,copy)   NSString  * enventDesc;
@property (nonatomic,copy)   NSString  * location;
@property (nonatomic,copy)   NSString  * createTime;
@property (nonatomic,copy)   NSString  * status;
@property (nonatomic,copy)   NSString  * canProposeTime;
@property (nonatomic,retain) NSArray   * invitees;
@property (nonatomic,retain) NSArray   * proposeTimes;
@property (nonatomic,retain) NSArray   * voteRecords;
@property (nonatomic,copy)   NSString  * img;
@property (nonatomic,copy)   NSString  * thumbnail;

@end