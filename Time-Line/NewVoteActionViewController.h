//
//  NewVoteActionViewController.h
//  Go2
//
//  Created by IF on 14/12/22.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NewVoteActionViewControllerDelegate;
@interface NewVoteActionViewController : UIViewController

@property (nonatomic, retain) id <NewVoteActionViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, retain) NSDictionary *voteOptionDic;

@end



@protocol NewVoteActionViewControllerDelegate <NSObject>

@optional
/**
 *  实现该代理会给你相应的值
 *
 *  @param newVoteViewVc 该视图
 *  @param question      添加的问题
 *  @param allow         是否允许成员添加问题（1.表示允许，0表示不允许）
 *  @param childArr      该问题的子选项
 */
- (void)newVoteActionViewController:(NewVoteActionViewController *)newVoteViewVc mainQuestion:(NSString *)question allowAddQuestion:(NSInteger)allow childQuestion:(NSArray *)childArr optionId:(NSString *)optionId isEdit:(BOOL)isModify;

@end
