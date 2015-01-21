//
//  AliasModifyViewController.h
//  Time-Line
//
//  Created by IF on 15/1/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@ class AliasModifyViewController ;
typedef void (^AliasModify) (AliasModifyViewController * selfViewCOntroller,NSString * modifyAlias ) ;

@interface AliasModifyViewController : UIViewController


@property (nonatomic, strong) NSString * fid ; //好友的id ；
@property (nonatomic, strong) NSString * alias ; //别名 ；

@property (nonatomic, copy) AliasModify aliasModify ;
@end