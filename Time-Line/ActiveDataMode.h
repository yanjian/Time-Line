//
//  ActiveDataMode.h
//  Go2
//
//  Created by IF on 15/3/31.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveDataMode : BaseMode
@property (nonatomic , copy)    NSString       * Id;//编辑才用
@property (nonatomic , retain ) UIImage        * activeImg;
@property (nonatomic , copy   ) NSString       * activeTitle;
@property (nonatomic , copy   ) NSString       * activeDesc ;
@property (nonatomic , copy   ) NSString       * activeLocName ;
@property (nonatomic , retain ) NSDictionary   * activeCoordinate;
@property (nonatomic , retain)  NSDate         * activeDueVoteDate;
@property (nonatomic , retain)  NSMutableArray * activeFriendArr ;
@property (nonatomic , retain)  NSMutableArray * activeVoteDate ;
@end
