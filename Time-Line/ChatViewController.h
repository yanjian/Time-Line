//
//  ChatViewController.h
//  Time-Line
//
//  Created by IF on 15/3/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "ChatModelData.h"
#import "ActiveEventMode.h"

@interface ChatViewController : JSQMessagesViewController

@property (strong, nonatomic) ChatModelData *chatModelData;

@property (strong, nonatomic) ActiveEventMode *activeEvent ;

@end
