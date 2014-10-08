///
//  MAGridView.h
//  Time-Line
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAGridView : UIView {
	unsigned int _rows;
	unsigned int _columns;
	BOOL _horizontalLines;
	BOOL _verticalLines;
	BOOL _outerBorder;
	CGFloat _lineWidth;
	UIColor *_lineColor;
}

@property (readwrite,assign) unsigned int rows;
@property (readwrite,assign) unsigned int columns;
@property (readwrite,assign) BOOL horizontalLines;
@property (readwrite,assign) BOOL verticalLines;
@property (readwrite,assign) BOOL outerBorder;
@property (readwrite,assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (readonly) CGFloat cellWidth;
@property (readonly) CGFloat cellHeight;

@end
