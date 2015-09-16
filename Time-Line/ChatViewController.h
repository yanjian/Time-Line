//
//  ChatViewController.h
//  Go2
//
//  Created by IF on 15/3/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "ChatModelData.h"
#import "ActiveEventModel.h"
#import "XLPagerTabStripViewController.h"

@interface ChatViewController : JSQMessagesViewController<XLPagerTabStripChildItem,UIActionSheetDelegate>{
   

}

@property (strong, nonatomic) ChatModelData *chatModelData;

@property (strong, nonatomic) ActiveEventModel *activeEvent ;

@end
