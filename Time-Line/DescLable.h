//
//  DescLable.h
//  Go2
//
//  Created by IF on 15/10/21.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VerticalAlignment)
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} ;


@interface DescLable : UILabel{
@private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end