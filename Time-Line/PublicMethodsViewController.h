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

//时间格式化为rfc3339
- (NSString *) rfc3339DateFormatter:(NSDate *) date;

-(NSString*)formaterStringfromDate:(NSString*)format dateString:(NSString *) dateString;

-(NSString*)stringFormaterDate:(NSString*)format dateString:(NSString *) dateString;

-(NSString *) dateWithStringDate:(NSString *) dateString;

-(NSMutableArray*)intervalSinceNow: (NSString *) theDate getStrart:(NSString*)startdate;
- (NSString *)intervalSinceNow: (NSString *) theDate;

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
