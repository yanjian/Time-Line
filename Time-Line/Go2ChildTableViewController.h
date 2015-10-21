//
//  Go2ChildTableViewController.h
//  Go2
//
//  Created by IF on 15/9/18.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "ARSegmentControllerDelegate.h"
#import "XHAudioPlayerHelper.h"
#import "ActiveEventModel.h"

@interface Go2ChildTableViewController : XHMessageTableViewController<ARSegmentControllerDelegate,XHAudioPlayerHelperDelegate>
@property (weak, nonatomic) ActiveEventModel * activeEvent;
@end
