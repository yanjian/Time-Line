//
//  PublicMethodsViewController.h
//  Time-Line
//
//  Created by zhoulei on 14-4-19.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicMethodsViewController : UIViewController

+(PublicMethodsViewController *)getPublicMethods;

-(NSString*)getcurrentTime:(NSString*)format;

-(NSString*)getonehourstime:(NSString*)format;

-(NSMutableArray*)intervalSinceNow: (NSString *) theDate getStrart:(NSString*)startdate;

- (NSString *)timeDifference: (NSString *) theDate getStrart:(NSString*)startdate;

-(void)setCorner:(UIView *)view radius:(float)cornerRadius borderWidth:(float)width;

- (NSString*)getWeekdayFromDate:(NSDate*)date;

-(UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize)newSize;

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect ;

-(NSString*)getseconde:(NSString*)endstart;

-(NSDate *) formatWithStringDate:(NSString *) stringDate;

-(NSString *) formatStringWithStringDate:(NSString *) dateString;

-(NSString *) formatStringWithString:(NSString *) stringDate;
@end
