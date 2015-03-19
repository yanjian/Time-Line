//
//  MemberDataModel.h
//  Time-Line
//
//  Created by IF on 15/3/11.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@interface MemberDataModel : BaseMode


@property (retain,nonatomic) NSNumber  * clientType ;
@property (copy,nonatomic)   NSString  * deviceToken;
@property (retain,nonatomic) NSNumber  * eid ;
@property (copy,nonatomic)   NSString  * imgBig ;
@property (copy,nonatomic)   NSString  * imgSmall ;
@property (retain,nonatomic) NSNumber  * join ;
@property (copy,nonatomic)   NSString  * nickname ;
@property (copy,nonatomic)   NSString  * notification;
@property (retain,nonatomic) NSNumber  * status;
@property (retain,nonatomic) NSNumber  * uid ;
@property (copy,nonatomic)   NSString  * username ;
@property (retain,nonatomic) NSNumber  * view ;

@end
