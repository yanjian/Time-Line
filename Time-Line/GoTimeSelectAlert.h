//
//  GoTimeSelectAlert.h
//  CalendarGoUtil
//
//  Created by IF on 15/7/2.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoAlertView.h"
@class GoTimeSelectAlert ;

@protocol GoTimeSelectAlertDelegate <NSObject>

@optional
-(void)goTimeSelectAlert:(GoTimeSelectAlert *) goTimeAlert selectValue:(NSArray *) selectArr ;

@end

@interface GoTimeSelectAlert : UIView

@property (nonatomic,retain) UIPickerView * pickerView ;
@property (nonatomic,assign) id<GoTimeSelectAlertDelegate> delegate;

@end
