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
#import "AnyEvent.h"

@interface AddEventViewController : UITableViewController<settimeDay,getlocationDelegate,getimagename,getNotesDelegate,UITextFieldDelegate>

@property(retain,nonatomic)NSString *state;                         //state的值为edit表示编辑数据，
@property(retain,nonatomic)NSDictionary *dateDic;                   //要编辑的事件数据(没有用咯)
@property(retain,nonatomic)NSMutableArray *dateArr;                        //用户所有的事件数据
@property (nonatomic, strong) NSMutableArray *arrGoogleCalendars;
@property (nonatomic, strong) NSDictionary *dictCurrentCalendar;
@property (nonatomic, strong) NSDate *dtEvent;
@property (nonatomic, strong) NSString *strEvent;
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;
@property (nonatomic,retain) AnyEvent *event;
@end
