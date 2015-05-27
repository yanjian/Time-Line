//
//  RepeatCalViewController.h
//  Go2
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define none  @"None"
#define dayly  @"Daily"
#define weekly  @"Weekly"
#define yearly  @"Yearly"
#define monthly  @"Monthly"
@protocol RepeatCalViewControllerDelegate;
@interface RepeatCalViewController : UIViewController

@property (nonatomic, retain) id <RepeatCalViewControllerDelegate> delegate;

@end


@protocol RepeatCalViewControllerDelegate <NSObject>

- (void)repeatCalViewController:(UIViewController *)controle selectData:(NSString *)dateString;

@end
