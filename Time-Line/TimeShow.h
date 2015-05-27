//
//  TimeShow.h
//  Go2
//
//  Created by IF on 15/4/21.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface TimeShow : UILabel
@property (nonatomic) VerticalAlignment verticalAlignment;
@end
