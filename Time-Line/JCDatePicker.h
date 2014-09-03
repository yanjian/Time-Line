//
//  JCDatePicker.h
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class JCDatePicker;

@protocol JCDatePickerDelegate <NSObject>

@optional

- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSString *)date;

@end

typedef NS_ENUM(NSInteger, JCDateFormat) {
    JCDateFormatFull = 0,
    JCDateFormatDay,
    JCDateFormatClock
};

@interface JCDatePicker : UIControl <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) JCDateFormat dateFormat;
@property (nonatomic) NSInteger startYear;
@property (nonatomic) NSInteger yearRange;
@property (nonatomic) NSRange rangeOfYear;
@property (nonatomic, weak) id delegate;
@property (nonatomic,retain) NSString* date;
@property (nonatomic, strong) UIColor *pickerColor;
@property (nonatomic, strong) UIColor *separatorLineColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *bgColor;
@property(nonatomic,strong)  NSArray* hourAtty;;
@property(nonatomic,strong)  NSArray* dayArray;;
@property(nonatomic,strong)  NSArray* minArray;;
@end

