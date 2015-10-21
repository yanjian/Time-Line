//
//  ARSegmentPageController.h
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentControllerDelegate.h"
#import "ARSegmentPageHeader.h"
#import "ARSegmentPageControllerHeaderProtocol.h"


@protocol ARSegmentPageControllerDelegate;

@interface ARSegmentPageController : UIViewController

@property (nonatomic, assign) CGFloat segmentHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat segmentMiniTopInset;
@property (nonatomic, assign, readonly) CGFloat segmentToInset;

@property (nonatomic, weak, readonly) UIViewController<ARSegmentControllerDelegate> *currentDisplayController;

@property (nonatomic, strong, readonly) UIView<ARSegmentPageControllerHeaderProtocol> *headerView;

@property (nonatomic, assign) BOOL freezenHeaderWhenReachMaxHeaderHeight;

@property (nonatomic, assign) id<ARSegmentPageControllerDelegate> delegate;

-(instancetype)initWithControllers:(UIViewController<ARSegmentControllerDelegate> *)controller,... NS_REQUIRES_NIL_TERMINATION;

-(void)setViewControllers:(NSArray *)viewControllers;

//override this method to custom your own header view
-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView;

@end

@protocol ARSegmentPageControllerDelegate <NSObject>

-(void)closeSegmentPageController:(ARSegmentPageController *) arSegmentPageController;
-(void)openActiveSetingTableViewController:(ARSegmentPageController *)arSegmentPageController;
@end