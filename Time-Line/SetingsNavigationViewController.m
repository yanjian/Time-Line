//
//  SetingsViewController.m
//  Time-Line
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "SetingsNavigationViewController.h"
#import "SetingViewController.h"
@interface SetingsNavigationViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation SetingsNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak SetingsNavigationViewController *weakSelf = self;
     if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
            self.interactivePopGestureRecognizer.delegate=weakSelf;
            self.delegate=weakSelf;
        }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.enabled = NO;
    [super pushViewController:viewController animated:animated];
}


- (void)navigationController:(UINavigationController *)navigationController  didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{

    NSArray *views=self.viewControllers;
    if (views.count<=1) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
            self.interactivePopGestureRecognizer.enabled = NO;
    }else{
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
            self.interactivePopGestureRecognizer.enabled = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
