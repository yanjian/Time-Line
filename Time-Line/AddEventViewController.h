//
//  AddEventViewController.h
//  Time-Line
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "LocationViewController.h"
#import "HomeViewController.h"
#import "BackGroundViewController.h"
#import "NotesViewController.h"
@interface AddEventViewController : UITableViewController<settimeDay,getlocationDelegate,getimagename,getNotesDelegate,UITextFieldDelegate>

@property(retain,nonatomic)NSString* state;
@property(retain,nonatomic)NSDictionary* dateDic;
@property(retain,nonatomic)NSArray* dateArr;
@property (nonatomic, strong) NSMutableArray *arrGoogleCalendars;
@property (nonatomic, strong) NSDictionary *dictCurrentCalendar;
@property (nonatomic, strong) NSDate *dtEvent;
@property (nonatomic, strong) NSString *strEvent;
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;
@end
