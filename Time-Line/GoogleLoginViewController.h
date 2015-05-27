//
//  GoogleLoginViewController.h
//  Go2
//
//  Created by IF on 14-9-26.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GoogleLoginViewControllerDelegate;
@interface GoogleLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *googleLoginView;
@property (assign, nonatomic) BOOL isLogin;
@property (assign, nonatomic)  BOOL isBind;
@property (strong, nonatomic) id <GoogleLoginViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isSeting;
@property (nonatomic, assign) BOOL isSync;
@end


@protocol GoogleLoginViewControllerDelegate <NSObject>

- (void)setGoogleCalendarListData:(NSArray *)googleArr;

@end
