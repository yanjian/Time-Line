//
//  Friend.m
//  Time-Line
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "Friend.h"

@implementation Friend


+ (instancetype)friendWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(void)setImgBig:(NSString *)imgBig{
    if (imgBig) {
         _imgBig= [imgBig stringByReplacingOccurrencesOfString:@"\\" withString:@"/"] ;
    }
}

-(void)setImgSmall:(NSString *)imgSmall{
    if (imgSmall) {
        _imgSmall = [imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"] ;
    }
}

@end
