//
//  GoTimeSelectAlert.m
//  CalendarGoUtil
//
//  Created by IF on 15/7/2.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import "GoTimeSelectAlert.h"
#import "GoAlertView.h"

@interface GoTimeSelectAlert()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic) NSArray  * hourArr   ;
@property (nonatomic) NSArray  * minuteArr ;
@property (nonatomic ,retain)  NSMutableArray * varArr;
@end


@implementation GoTimeSelectAlert



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hourArr = @[@"1",@"2",@"3",@"4",@"5",@"6"];
        self.minuteArr = @[@"0",@"15",@"30",@"45"];
        self.varArr =@[@"1",@"0"].mutableCopy ;
        [self setup];
        self.layer.cornerRadius = 5;
    }
    return self;
}




-(void)setup{
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0,self.bounds.size.width, 100)];
    self.pickerView.dataSource = self ;
    self.pickerView.delegate   = self ;
    [self addSubview:self.pickerView];
    
    
    UIView * horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(self.pickerView.frame.origin.x,self.pickerView.frame.origin.y+self.pickerView.frame.size.height-1,  self.pickerView.frame.size.width, 1)];
    horizonSperatorView.backgroundColor = RGBA(218, 218, 222, 1.0);
    [self addSubview:horizonSperatorView];
    
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(self.pickerView.frame.origin.x, self.pickerView.frame.origin.y+self.pickerView.frame.size.height, self.pickerView.frame.size.width/2, 50) ;
    [leftBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    leftBtn.backgroundColor = [UIColor whiteColor] ;
    leftBtn.tag = 1 ;
    [leftBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(clickBtnEvent:) forControlEvents:UIControlEventTouchUpInside] ;
    [self addSubview:leftBtn] ;
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(leftBtn.frame.origin.x+leftBtn.frame.size.width, leftBtn.frame.origin.y, self.pickerView.frame.size.width/2, 50) ;
    [rightBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor whiteColor] ;
    rightBtn.tag = 2 ;
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(clickBtnEvent:) forControlEvents:UIControlEventTouchUpInside] ;
    [self addSubview:rightBtn] ;
    
    
    UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(rightBtn.frame.size.width, rightBtn.frame.origin.y, 1, rightBtn.frame.size.height+3)];
    verticalSeperatorView.backgroundColor = RGBA(218, 218, 222, 1.0);
    [self addSubview:verticalSeperatorView];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 4 ;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 1 ;
    }else if (component == 1){
        return self.hourArr.count ;
    }else if (component == 2){
        return 1 ;
    }else{
        return self.minuteArr.count ;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return @"Hour" ;
    }else if (component == 1){
        return self.hourArr[row];
    }else if (component == 2){
        return @"Minute" ;
    }else{
        return self.minuteArr[row] ;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return 80.f ;
    }else if (component == 1){
        return 40.f;
    }else if (component == 2){
        return 80.f ;
    }else{
        return 40.f;
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 1) {
        NSString * hourStr = self.hourArr[row];
        if (![[self.varArr firstObject] isEqualToString:hourStr]) {
            [self.varArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
            [self.varArr insertObject:hourStr atIndex:0];
        }
    }else if (component == 3){
        NSString * minuteStr = self.minuteArr[row];
        if (![[self.varArr lastObject] isEqualToString:minuteStr]) {
            [self.varArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:1]];
            [self.varArr addObject:minuteStr];
        }
    }
    NSLog(@"%@",self.varArr);
}

-(void)clickBtnEvent:(UIButton *) sender {
    switch (sender.tag) {
        case 1:{
            GoAlertView * sgoAlertView = (GoAlertView *) self.superview ;
            [sgoAlertView hide];
        }break;
        case 2:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(goTimeSelectAlert:selectValue:)]) {
                [self.delegate goTimeSelectAlert:self selectValue:self.varArr] ;
            }
            GoAlertView * sgoAlertView = (GoAlertView *)self.superview ;
            [sgoAlertView hide];
        } break ;
            
        default:
            break;
    }
}

@end
