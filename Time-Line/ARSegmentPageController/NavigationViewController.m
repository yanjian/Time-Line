//
//  NavigationViewController.m
//  ARSegmentPager
//
//  Created by August on 15/5/9.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               [UIFont systemFontOfSize:18],
                                               NSFontAttributeName, nil];
    
    [self.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [self.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationBar setShadowImage:[self createImageWithColor:[UIColor blueColor]]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
  //  [self.navigationBar setTranslucent:YES];
    
    //全屏滑动
//    id tag = self.interactivePopGestureRecognizer.delegate;
//    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:tag action:@selector(handleNavigationTransition:)];
//    panRec.delegate = self ;
//    [self.view addGestureRecognizer:panRec];
//    self.interactivePopGestureRecognizer.enabled = NO ;

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.childViewControllers.count ==1) {
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent ;
}


-(UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
