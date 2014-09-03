//
//  NotesViewController.h
//  Time-Line
//
//  Created by connor on 14-4-23.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol getNotesDelegate <NSObject>
-(void)getnotes:(NSString*)notestr;
@end
@interface NotesViewController : UIViewController<UITextViewDelegate>

@property (retain, nonatomic) UITextView *noteText;
@property (nonatomic, weak) id<getNotesDelegate> delegate;
@end
