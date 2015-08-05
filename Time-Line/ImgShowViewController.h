//
//  ImgShowViewController.h
//
//  图片展示控件
//
//  Created by Minr on 14-11-14.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgShowViewController :UIViewController

@property(nonatomic ,assign)NSInteger index;
@property(nonatomic ,retain)NSMutableArray *data;

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index;

@end

