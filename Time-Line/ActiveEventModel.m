//
//  ActiveEventModel.m
//  Go2
//
//  Created by IF on 15/8/12.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveEventModel.h"

@implementation ActiveEventModel

-(NSDictionary *)propertyMapDic{
   
    return @{
                @"id":@"Id",
                @"createId":@"createId",
                @"title":@"title",
                @"description":@"enventDesc",
                @"location":@"location",
                @"createTime":@"createTime",
                @"status":@"status",
                @"canProposeTime":@"canProposeTime",
                @"invitees":@"invitees",
                @"proposeTimes":@"proposeTimes",
                @"voteRecords":@"voteRecords",
                @"img":@"img",
                @"thumbnail":@"thumbnail"
             };
}


@end
