//
//  Go2StandardEventView.m
//  CalendarGoUtil
//
//  Created by IF on 15/7/16.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import "Go2StandardEventView.h"

@interface Go2StandardEventView ()
@property (nonatomic) UIView *leftBorderView;

@property (nonatomic) NSMutableAttributedString *attrString;

@end

@implementation Go2StandardEventView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        
        _color = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        _leftBorderView = [[UIView alloc]initWithFrame:CGRectNull];
        [self addSubview:_leftBorderView];
    
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteHandleSelfView:)] ;
        [self addGestureRecognizer:tapGestureRecognizer] ;
    }
    return self ;
}

- (void)redrawStringInRect:(CGRect)rect
{
    // attributed string can't be created with nil string
    NSMutableString *s = [NSMutableString stringWithString:@""];
    
    if (self.title) {
        [s appendString:self.title];
    }
    
    UIFont *boldFont = [UIFont fontWithDescriptor:[[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.font.pointSize];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName: boldFont ?: self.font }];
    
    if (self.subtitle) {
        NSMutableString *s  = [NSMutableString stringWithFormat:@"\n%@", self.subtitle];
        NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName:self.font}];
        [as appendAttributedString:subtitle];
    }
    
    if (self.detail) {
        UIFont *smallFont = [UIFont fontWithDescriptor:[self.font fontDescriptor] size:self.font.pointSize - 2];
        NSMutableString *s = [NSMutableString stringWithFormat:@"\t%@", self.detail];
        NSMutableAttributedString *detail = [[NSMutableAttributedString alloc]initWithString:s attributes:@{NSFontAttributeName:smallFont}];
        [as appendAttributedString:detail];
    }
    
    NSTextTab *t = [[NSTextTab alloc]initWithTextAlignment:NSTextAlignmentRight location:rect.size.width options:nil];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.tabStops = @[t];
    //style.hyphenationFactor = .4;
    //style.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [as addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, as.length)];
    
    UIColor *color = self.selected ? [UIColor whiteColor] : self.color;
    [as addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, as.length)];
    
    self.attrString = as;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.leftBorderView.frame = CGRectMake(0, 0, 2, self.bounds.size.height);
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor*)color
{
    _color = color;
}


- (void)setSelected:(BOOL)selected
{
    _selected = selected ;
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawRect = CGRectInset(rect, 1, 0);
    [self redrawStringInRect:drawRect];
    
    CGRect boundingRect = [self.attrString boundingRectWithSize:drawRect.size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    drawRect.size.height = fminf(drawRect.size.height, 60);
    
    if (boundingRect.size.height > drawRect.size.height) {
        [self.attrString.mutableString replaceOccurrencesOfString:@"\n" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.attrString.length)];
    }
    
    [self.attrString drawWithRect:drawRect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil];
}

-(void)deleteHandleSelfView:(UITapGestureRecognizer *) gestureRecognizer{
    if (self.superview) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteGo2StandardEventView:deleteSelectDateDic:)]) {
            [self.delegate deleteGo2StandardEventView:self deleteSelectDateDic:self.selectDic];
        
        }
        [self removeFromSuperview] ;
    }
    
}

@end
