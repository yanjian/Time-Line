//
//  FDAlertView.h
//  Go2
//
//  Created by IF on 15/4/24.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoAlertViewDelegate;

@interface GoAlertView : UIView

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) id<GoAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message delegate:(id<GoAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// Show the alert view in current window
- (void)show;

// Hide the alert view
- (void)hide;

// Set the color and font size of title, if color is nil, default is black. if fontsize is 0, default is 14
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of message, if color is nil, default is black. if fontsize is 0, default is 12
- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of button at the index, if color is nil, default is black. if fontsize is 0, default is 16
- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index;

@end

@protocol GoAlertViewDelegate <NSObject>

- (void)alertView:(GoAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
