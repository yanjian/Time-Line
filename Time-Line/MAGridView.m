//
//  MAGridView.m
//  Go2
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "MAGridView.h"

@interface MAGridView (PrivateMethods)
- (void)setupCustomInitialisation;
@end

@implementation MAGridView

@synthesize horizontalLines=_horizontalLines;
@synthesize verticalLines=_verticalLines;
@synthesize lineWidth=_lineWidth;
@synthesize lineColor=_lineColor;
@synthesize outerBorder=_outerBorder;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setupCustomInitialisation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self setupCustomInitialisation];
	}
	return self;
}


- (void)setupCustomInitialisation {
	self.rows             = 8;
	self.columns          = 8;
	self.lineWidth        = 1;
	self.horizontalLines  = YES;
	self.verticalLines    = YES;
	self.outerBorder      = YES;
	self.lineColor        = [UIColor lightGrayColor]; // retain
}

- (void)setRows:(unsigned int)rows {
	_rows = rows;
}

- (void)setColumns:(unsigned int)columns {
	_columns = columns;
}

- (unsigned int)rows {
	return _rows;
}

- (unsigned int)columns {
	return _columns;
}

- (CGFloat)cellWidth {
	if (_columns > 0) {
		return self.bounds.size.width  / _columns;
	} else {
		return 0;
	}
}

- (CGFloat)cellHeight {
	if (_rows > 0) {
		return self.bounds.size.height / _rows;
	} else {
		return 0;
	}
}

- (void)drawRect:(CGRect)rect {
	if (!(_columns > 0 && _rows > 0)) {
		// Nothing to draw
		return;
	}
	
    CGFloat cellHeight = self.cellHeight;
    CGFloat cellWidth = self.cellWidth;
	register unsigned int i;
	CGFloat x, y;
	
	const CGContextRef c          = UIGraphicsGetCurrentContext();
	const CGFloat      lineMiddle = _lineWidth / 2.f;
	
	CGContextSetStrokeColorWithColor(c, [_lineColor CGColor]);
	CGContextSetLineWidth(c, _lineWidth);
	
	CGContextBeginPath(c); {
		x = CGRectGetMinX(rect);
		y = CGRectGetMinY(rect);
		
		for (i=0; i <= _rows && _horizontalLines; i++) {
			if (i == 0) {
				y += lineMiddle;
				if (!_outerBorder) goto NEXT_ROW;
			} else if (i == _rows) {
				y = CGRectGetMaxY(rect) - lineMiddle;
				if (!_outerBorder) goto NEXT_ROW;
			}
			
			CGContextMoveToPoint(c, x, y);
			CGContextAddLineToPoint(c, self.bounds.size.width, y);
			
		NEXT_ROW:
			y += cellHeight;
		}
		
		x = CGRectGetMinX(rect);
		y = CGRectGetMinY(rect);
		
		for (i=0; i <= _columns && _verticalLines; i++) {
			if (i == 0) {
				x += lineMiddle;
				if (!_outerBorder) goto NEXT_COLUMN;
			} else if (i == _columns) {
				x = CGRectGetMaxX(rect) - lineMiddle;
				if (!_outerBorder) goto NEXT_COLUMN;
			}
		
			CGContextMoveToPoint(c, x, y);
			CGContextAddLineToPoint(c, x, self.bounds.size.height);
			
		NEXT_COLUMN:
			x += cellWidth;
		}
	}
	
	CGContextClosePath(c);
	CGContextSaveGState(c);
	CGContextDrawPath(c, kCGPathFillStroke);
	CGContextRestoreGState(c);
}

@end