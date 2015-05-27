//
//  LoginViewController.h
//  Go2
//
//  Created by IF on 14-9-26.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;
@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *googleLoginBtn;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *passwordBtn;
@property (weak, nonatomic) IBOutlet UIButton *ourLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardScorllView;

@end
