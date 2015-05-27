//
//  MemberDataModel.m
//  Go2
//
//  Created by IF on 15/3/11.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "MemberDataModel.h"

@implementation MemberDataModel

-(void)setImgBig:(NSString *)imgBig{
    _imgBig = [imgBig stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
}

-(void)setImgSmall:(NSString *)imgSmall{
    _imgSmall = [_imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
}
@end
