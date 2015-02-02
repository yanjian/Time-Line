//
//  SegmentedControl.m
//  SegmentedControlNavigation
//
//  Created by IF on 5/30/14.
//  Copyright (c) 2014 IF. All rights reserved.
//

#import "SegmentedControl.h"

@implementation SegmentedControl {
	NSArray *buttons;
	UIButton *noticesButton; // 通知 按钮
	UIButton *manageButton; // 管理 按钮
	UIButton *friendsButton; // 朋友列表 按钮
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self initialize]; //调用自定义的方法
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)initialize {
	noticesButton = [[UIButton alloc] init];
	[noticesButton.layer setMasksToBounds:YES];
	[noticesButton.layer setBorderWidth:1.f];
	[noticesButton.layer setBorderColor:[UIColor whiteColor].CGColor];
	[noticesButton setTitle:@"Notices" forState:UIControlStateNormal];
	noticesButton.frame = CGRectMake(0, 0, 70, 32);
	[self addSubview:noticesButton];

	manageButton = [[UIButton alloc] init];
	[manageButton.layer setMasksToBounds:YES];
	[manageButton.layer setBorderWidth:1.f];
	[manageButton.layer setBorderColor:[UIColor whiteColor].CGColor];
	[manageButton setTitle:@"Manage" forState:UIControlStateNormal];
	manageButton.frame = CGRectMake(70, 0, 70, 32);
	[self addSubview:manageButton];

	friendsButton = [[UIButton alloc] init];
	[friendsButton.layer setMasksToBounds:YES];
	[friendsButton.layer setBorderWidth:1.f];
	[friendsButton.layer setBorderColor:[UIColor whiteColor].CGColor];
	[friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
	friendsButton.frame = CGRectMake(140, 0, 70, 32);
	[self addSubview:friendsButton];

	[noticesButton addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
	[manageButton addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
	[friendsButton addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];

	buttons = @[noticesButton, manageButton, friendsButton];

	self.selectedSegmentIndex = UISegmentedControlNoSegment;

	[self sizeToFit];

	NSLog(@"SegmentedControl initialize");
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(210, 32);
}

- (void)touchUpInsideAction:(UIButton *)button {
	NSLog(@"SegmentedControl touchUpInsideAction");
	for (UIButton *button in buttons) {
		button.selected = NO;
	}
	button.selected = YES;
	NSInteger index = [buttons indexOfObject:button];
	if (self.selectedSegmentIndex != index) {
		self.selectedSegmentIndex = index;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

@end
