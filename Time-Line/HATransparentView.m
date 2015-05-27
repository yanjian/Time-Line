//
//  HATransparentView.m
//  HATransparentView
//
//  Created by Heberti Almeida on 13/09/13.
//  Copyright (c) 2013 Heberti Almeida. All rights reserved.
//

#import "HATransparentView.h"
#import "DayTimeView.h"
#import "TimeSelectView.h"

#define kDefaultBackground [UIColor colorWithWhite:0.0 alpha:0.5];

@interface HATransparentView ()<DayTimeViewDelegate,TimeSelectViewDelegate,UIGestureRecognizerDelegate>{
    UIScrollView * scrollView ;
    DayTimeView * dayTimeView ;
    TimeSelectView * timeView ;

}

@property(nonatomic, assign) NSInteger statusBarStyle;

@end

@implementation HATransparentView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.frame = [[UIScreen mainScreen] bounds];
    self.opaque = NO;
    self.backgroundColor = kDefaultBackground;
    self.tapBackgroundToClose = NO;
      
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-50)];
    //scrollView.contentSize = CGSizeMake(kScreen_Width*2, 0);
      scrollView.contentSize = CGSizeMake(kScreen_Width, 0);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;//最后一页滑不动
    scrollView.showsHorizontalScrollIndicator=NO;
    //[self createDayTimeView];  暂时屏蔽
    [self createTimeSelectView];
  }
  return self;
}


-(void)createDayTimeView{
    dayTimeView = [[DayTimeView alloc] initWithFrame:CGRectMake(5, 20, scrollView.bounds.size.width-10, scrollView.bounds.size.height-20)];
    dayTimeView.delegate = self ;
    [scrollView addSubview:dayTimeView];
}

-(void)createTimeSelectView{
//    //第二个视图
//    timeView = [[TimeSelectView alloc] initWithFrame:CGRectMake(scrollView.bounds.size.width+15, 30, scrollView.bounds.size.width-30, scrollView.bounds.size.height-30)];
    
    timeView = [[TimeSelectView alloc] initWithFrame:CGRectMake(15, 30, scrollView.bounds.size.width-30, scrollView.bounds.size.height-30)];
    
    timeView.timeViewDelegate = self ;
    [scrollView addSubview:timeView];
    
    [self addSubview:scrollView];
}

-(void)clickDayTimeToolLeftButton:(UIBarButtonItem *) barButtonItem{
        [UIView animateWithDuration:0.3f
                         animations:^{
                             scrollView.contentOffset = CGPointMake(kScreen_Width, 0);
                         }];
    
}


//--------------start ------------
#pragma  mark -TimeSelectViewDelegate的代理
-(void)clickTimeSelectToolLeftButton:(UIBarButtonItem *) barButtonItem {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         scrollView.contentOffset = CGPointMake(0, 0);
                     }];

}

//-------------end-----------------
- (void)tapBackgroundToClose:(BOOL)close {
  if (close) {
    [self addTapGestureRecognizer];
  }
}


#pragma mark - Open Transparent View
- (void)open {
  // Get main window reference
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  if (!window){
     window = [[UIApplication sharedApplication].windows objectAtIndex:0];
  }

  self.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];

  CATransition *viewIn = [CATransition animation];
  [viewIn setDuration:0.4];
  [viewIn setType:kCATransitionReveal];
  [viewIn setTimingFunction:[CAMediaTimingFunction
                            functionWithName:kCAMediaTimingFunctionEaseOut]];
  [[self layer] addAnimation:viewIn forKey:kCATransitionReveal];

  [[[window subviews] objectAtIndex:0] addSubview:self];
}

#pragma mark - Close Transparent View
- (void)close {
  CATransition *viewOut = [CATransition animation];
  [viewOut setDuration:0.3];
  [viewOut setType:kCATransitionFade];
  [viewOut setTimingFunction:
               [CAMediaTimingFunction
                   functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [[self.superview layer] addAnimation:viewOut forKey:kCATransitionFade];

  [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
  [self removeFromSuperview];
  if (self.delegate && [self.delegate respondsToSelector:@selector(hATransparentViewDidClosed)]) {
         [self.delegate hATransparentViewDidClosed];
  }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (CGRectContainsPoint(dayTimeView.frame, [gestureRecognizer locationInView:dayTimeView])) {
        return NO;
    }else if(CGRectContainsPoint(timeView.frame, [gestureRecognizer locationInView:timeView])){
        return NO;
    }
             return YES;
}

#pragma mark - UITapGestureRecognizer
- (void)addTapGestureRecognizer {
  UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(close:)];
    tapGesture.delegate = self ;
  [self addGestureRecognizer:tapGesture];
}

- (void)close:(UITapGestureRecognizer *)sender {
        [self close];
}

#pragma mark - TimeSelectViewDelegate
-(void)timeSelectView:(TimeSelectView *) selectView dateDic:(NSDictionary *) dateDic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(hATransparentViewDidSelectDate:)]) {
        [self.delegate hATransparentViewDidSelectDate:dateDic] ;
    }
    [self close];
}
@end