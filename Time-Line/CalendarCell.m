//
//  CalendarCell.m
//  Time-Line
//
//  Created by zhoulei on 14-5-3.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "CalendarCell.h"

@implementation CalendarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _btnArray = [NSMutableArray arrayWithCapacity:7];
        _bgArray = [NSMutableArray arrayWithCapacity:7];
        _pointArray = [NSMutableArray arrayWithCapacity:7];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //日历的背景色
        self.backgroundColor = [UIColor whiteColor];
        
        for (int i = 0; i < 7; i++)
        {
            //日历中的每个日期的背景
            UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width/7*i+12.3, 7.8, 25, 25)];
            [_bgArray addObject:bgView];
            [self addSubview:bgView];
            
            //日历中的每个按钮
            UIButton* lab = [[UIButton alloc]initWithFrame:CGRectMake(kScreen_Width/7*i+3 , 0, kScreen_Width/7, 40)];
            lab.titleLabel.font = [UIFont boldSystemFontOfSize:13]; // font=15
            [lab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            lab.backgroundColor = [UIColor clearColor]; // 透明色
            [lab setTitle:@"1" forState:UIControlStateNormal];
            [lab addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
            lab.tag = i;
            [_btnArray addObject:lab];
            [self addSubview:lab];
            
            //当某天下面有事件时显示一个点
            UIImageView *pointView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width/7*i+22, bgView.bounds.size.height+9, 7, 7)];
            [_pointArray addObject:pointView];
            [self addSubview:pointView];
            
        }
    }
    return self;
}

- (void)setWeekArr:(NSArray *)weekArr
{
    for (int i = 0; i < weekArr.count && i < _btnArray.count; i++) {
        
        UIButton *temp = [_btnArray objectAtIndex:i];
        UIImageView *tempBgView = [_bgArray objectAtIndex:i];
        UIImageView *pointView = [_pointArray objectAtIndex:i];
        CLDay *day = [weekArr objectAtIndex:i];
        
        [temp setTitle:[NSString stringWithFormat:@"%i", day.day] forState:UIControlStateNormal];
        
        [temp setTitleColor:grayColors forState:UIControlStateNormal];
        /* 调整显示月份字体颜色 */
        if ([self.detelegate getShowMonths] == day.month) {
            //当前月份的颜色
            [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        _imageview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreen_Width/7*i , 35, kScreen_Width/7, 5)];
        //[self addSubview:_imageview];
        
        /* 调整背景色 */
        if ([self.detelegate getShowSelectDays:self] == i) {
            //点击的日期图片
            [tempBgView setImage:[UIImage imageNamed:@"Event_time_red"]];
            [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"day" object:day];
        } else {
            [tempBgView setImage:nil];
            
        }
        
        if (day.isSelectDay) {
            //当前日期的图片
            [tempBgView setImage:[UIImage imageNamed:@"Event_time_red"]];
            [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        //某天中是否存在数据
        if (day.isExistData) {
            [pointView setImage:[UIImage imageNamed:@"Icon_HaveEvent"]];
        }else{
            [pointView setImage:nil];
        }
        
    }
    _weekArr = weekArr;

}

- (void)selectDate:(UIButton*)dateBtn
{
    [self.detelegate selectDates:self weekDay:dateBtn.tag];
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
