//
//  MyCell.m
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//


#import "SCCell.h"
#import "SCHeadView.h"
#import "MeetModel.h"
@interface SCCell()<HeadViewDelegate>

@end

@implementation SCCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        for(int i=0;i<20;i++){
        
            SCHeadView *headView=[[SCHeadView alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth-kWidthMargin, kHeight+kHeightMargin)];
            headView.delegate=self;
            headView.backgroundColor=[UIColor whiteColor];
            [self.contentView addSubview:headView];
        }
        
    }
    return self;
}
-(void)headView:(SCHeadView *)headView point:(CGPoint)point
{
    if([self.delegate respondsToSelector:@selector(myHeadView:point:)]){
    
        [self.delegate myHeadView:headView point:point];
    }

}
-(void)setCurrentTime:(NSMutableArray *)currentTime
{
     _currentTime=currentTime;
    int count=currentTime.count;
    if(count>0){
        for(int i=0;i<count;i++){
        
            MeetModel *model=currentTime[i];
            
            SCHeadView *headView;
            if([model.meetRoom isEqualToString:@"000"]){
              
                headView=(SCHeadView *)self.contentView.subviews[0];
            }else{
               
                NSArray *room=[model.meetRoom componentsSeparatedByString:@"0"];
                headView=(SCHeadView *)self.contentView.subviews[[[room lastObject] intValue]];
            }
            headView.backgroundColor=[UIColor greenColor];
            
            for(SCHeadView *leftHeadView in self.contentView.subviews){
              
                if(headView!=leftHeadView) leftHeadView.backgroundColor=[UIColor whiteColor];
            }
        }
    }else{
       
        for(SCHeadView *headView in self.contentView.subviews){
        
            headView.backgroundColor=[UIColor whiteColor];
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
