//
//  ActiveTableViewCell.m
//  Time-Line
//
//  Created by IF on 14/12/6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ActiveTableViewCell.h"
@interface ActiveTableViewCell () <UIActionSheetDelegate>
{
}
@end

@implementation ActiveTableViewCell
@synthesize activeEvent;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWithFriendGroup:)];
	[self addGestureRecognizer:longPressGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)handleLongPressWithFriendGroup:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		UIActionSheet *asActiveSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:activeEvent.isHide ? @"Show" : @"Hide", activeEvent.isNotification ? @"Refused notification" : @"Receive notification", @"Quit", nil];
		[asActiveSheet showInView:self];
	}
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 3) {
		return;
	}
	NSMutableDictionary *paramDic = nil;
	NSString *urlStr = nil;
	NSInteger tag;
	ASIHTTPRequest *request;
	if (buttonIndex == 0) {//hide ==> button
		if (activeEvent.isHide) {
			paramDic = @{ @"eid":self.activeEvent.Id, @"type":@(1) }.mutableCopy;
		}
		else {
			paramDic = @{ @"eid":self.activeEvent.Id, @"type":@(2) }.mutableCopy;//不显示
		}
		urlStr = anyTime_ViewEvent;
		tag = anyTime_ViewEvent_tag;
		request = [t_Network httpGet:paramDic Url:urlStr Delegate:nil Tag:tag];
	}
	else if (buttonIndex == 1) {
		if (activeEvent.isNotification) {
			paramDic = @{ @"eid":self.activeEvent.Id, @"type":@(2) }.mutableCopy;
		}
		else {
			paramDic = @{ @"eid":self.activeEvent.Id, @"type":@(1) }.mutableCopy;
		}
		urlStr = anyTime_EventNotification;
		tag = anyTime_EventNotification_tag;
		request = [t_Network httpPostValue:paramDic Url:urlStr Delegate:nil Tag:tag];
	}
	else if (buttonIndex == 2) { // Quit ==> button
		paramDic = @{ @"eid":self.activeEvent.Id }.mutableCopy;
		urlStr = anyTime_QuitEvent;
		tag = anyTime_QuitEvent_tag;
		request = [t_Network httpPostValue:paramDic Url:urlStr Delegate:nil Tag:tag];
	}

	__block ASIHTTPRequest *deleteRequest = request;
	[request setCompletionBlock: ^{
	    NSString *responseStr = [deleteRequest responseString];
	    NSLog(@"%@", responseStr);
	    id objTmp = [responseStr objectFromJSONString];
	    NSString *statusCode = [objTmp objectForKey:@"statusCode"];
	    if ([statusCode isEqualToString:@"1"]) {
	        [MBProgressHUD showSuccess:@"Success"];

	        if (buttonIndex == 1) {
	            if (activeEvent.isNotification) {
	                activeEvent.isNotification = NO;
				}
	            else {
	                activeEvent.isNotification = YES;
				}
			}
	        else if (buttonIndex == 0) {//hide ==> button
	            if (activeEvent.isHide) {
	                activeEvent.isHide = NO;
				}
	            else {
	                activeEvent.isHide = YES;
				}
			}
	        else if (buttonIndex == 2) {  // Quit ==> button
	            //to  do
			}
		}
	}];
	[request setFailedBlock: ^{
	    NSError *error = [deleteRequest error];
	    if (error) {
	        [MBProgressHUD showError:@"Error"];
		}
	}];
	[request startAsynchronous];
}

@end