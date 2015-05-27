//
//  BackGroundViewController.h
//  Go2
//
//  Created by connor on 14-4-21.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"
@protocol getimagename <NSObject>
- (void)getimage:(NSString *)image;
@end
@interface BackGroundViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) id <getimagename> detelegate;
@property (nonatomic) UIPopoverController *popover;
@end
