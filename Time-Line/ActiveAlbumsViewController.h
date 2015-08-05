//
//  ActiveAlbumsViewController.h
//  Go2
//
//  Created by IF on 15/6/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
@interface ActiveAlbumsViewController : UIViewController<XLPagerTabStripChildItem>

@property (nonatomic,copy) NSString * eid ;

@property (nonatomic, retain) NSMutableArray *data;

@end
