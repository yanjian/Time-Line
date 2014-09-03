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
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        
        [temp setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        /* 调整显示月份字体颜色 */
        if ([self.detelegate getShowMonths] == day.month) {
            [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        /* 调整背景色 */
        if (day.isToday) {
            [tempBgView setImage:[UIImage imageNamed:@"daybackgrd2"]];
        } else if ([self.detelegate getShowSelectDays:self] == i) {
            [tempBgView setImage:[UIImage imageNamed:@"daybackgrd1"]];
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
