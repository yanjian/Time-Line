//
//  CLCalendarCell.m
//  Time-Line
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "CLCalendarCell.h"


@implementation CLCalendarCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _btnArray = [NSMutableArray arrayWithCapacity:7];
        _bgArray = [NSMutableArray arrayWithCapacity:7];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        日历的背景色
        self.backgroundColor = [UIColor whiteColor];
        
        for (int i = 0; i < 7; i++)
        {
            UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width/7*i+9.3, 7.8, 25, 25)];
            [_bgArray addObject:bgView];
            [self addSubview:bgView];
            
            UIButton* lab = [[UIButton alloc]initWithFrame:CGRectMake(kScreen_Width/7*i , 0, kScreen_Width/7, 40)];
            lab.titleLabel.font = [UIFont boldSystemFontOfSize:13]; // font=15
            [lab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            lab.backgroundColor = [UIColor clearColor]; // 透明色
            [lab setTitle:@"1" forState:UIControlStateNormal];
            [lab addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
            lab.tag = i;
            [_btnArray addObject:lab];
            [self addSubview:lab];
        }
    }

    return self;
}

- (void)setWeekArr:(NSArray *)weekArr
{
    for (int i = 0; i < weekArr.count && i < _btnArray.count; i++) {
        
        UIButton *temp = [_btnArray objectAtIndex:i];
        UIImageView *tempBgView = [_bgArray objectAtIndex:i];
        CLDay *day = [weekArr objectAtIndex:i];

        [temp setTitle:[NSString stringWithFormat:@"%i", day.day] forState:UIControlStateNormal];

        [temp setTitleColor:grayColors forState:UIControlStateNormal];
        /* 调整显示月份字体颜色 */
        if ([self.detelegate getShowMonth] == day.month) {
            
//            当前月份的颜色
            [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        _imageview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreen_Width/7*i , 35, kScreen_Width/7, 5)];
//        [self addSubview:_imageview];
        /* 调整背景色 */
        if (day.isToday) {
//            当前日期的图片
            [tempBgView setImage:[UIImage imageNamed:@"daybackgrd2"]];
        } else if ([self.detelegate getShowSelectDay:self] == i) {
            
//            点击的日期图片
            [tempBgView setImage:[UIImage imageNamed:@"daybackgrd2-1"]];
            [temp setTitleColor:blueColor forState:UIControlStateNormal];
           [[NSNotificationCenter defaultCenter] postNotificationName:@"day" object:day];

        } else {
            [tempBgView setImage:nil];
        }
    }
    _weekArr = weekArr;
}

- (void)selectDate:(UIButton*)dateBtn
{
    [self.detelegate selectDate:self weekDay:dateBtn.tag];
}

@end
