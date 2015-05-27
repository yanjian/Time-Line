//
//  LoginRegisterViewController.h
//  Go2
//
//  Created by IF on 14-9-28.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;
@interface LoginRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *LogInBtn;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *TPScollView;

@end
