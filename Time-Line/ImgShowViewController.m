//
//  ImgShowViewController.m
//  Project-Movie
//
//  Created by Minr on 14-11-14.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import "ImgShowViewController.h"
#import "MRImgShowView.h"

@interface ImgShowViewController ()<MRImgShowViewDelegate>

@end

@implementation ImgShowViewController

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index{
    
    self = [super init];
    if (self) {
        _data = data ;
        _index = index;
    }
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%i/%i",_index+1,_data.count ];
    
    //设置导航栏为半透明
    self.navigationController.navigationBar.translucent = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 添加导航栏退回按钮
     UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
    
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self creatImgShow];
}

// 初始化视图
- (void)creatImgShow{
    
    MRImgShowView *imgShowView = [[MRImgShowView alloc]
                                  initWithFrame:self.view.frame
                                    withSourceData:_data
                                    withIndex:_index
                                    withDelegate:self];
    
    // 解决谦让
    [imgShowView requireDoubleGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    
    [self.view addSubview:imgShowView];
}

// MRImgShowView 的代理
-(void)mRImgShowView:(MRImgShowView * )mRImgShowView currIndex:(NSInteger) currIndex{
    NSInteger tmpIndex  = currIndex+1<=0 ? _data.count : currIndex+1 > _data.count ? 1 : currIndex+1 ;
    self.title = [NSString stringWithFormat:@"%i/%i",tmpIndex,_data.count ];
}

#pragma mark -UIGestureReconginzer
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    // 隐藏导航栏
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -NavAction
- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
