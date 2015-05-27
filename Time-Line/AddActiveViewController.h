//
//  AddActiveViewController.h
//  Go2
//
//  Created by IF on 14/12/15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "LocationViewController.h"
#import "HomeViewController.h"
#import "NotesViewController.h"
#import "ActiveEventMode.h"
#import "AT_Event.h"
@interface AddActiveViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) BOOL isEdit; //Yes 标记这是编辑（修改）
@property (nonatomic, retain)  ActiveEventMode *activeEventMode;
@end
