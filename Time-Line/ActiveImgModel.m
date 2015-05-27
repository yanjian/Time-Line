//
//  ActiveImgModel.m
//  Go2
//
//  Created by IF on 15/4/8.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveImgModel.h"

@implementation ActiveImgModel

-(void)setImgBig:(NSString *)imgBig{
    _imgBig =[NSString stringWithFormat:@"%@/%@",BASEURL_IP,[imgBig stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]] ;
}

-(void)setImgSmall:(NSString *)imgSmall{
    _imgSmall = [NSString stringWithFormat:@"%@/%@",BASEURL_IP,[imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]];
}

@end
