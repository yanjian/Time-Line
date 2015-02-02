//
//  HeadView.m
//  Time-Line
//
//  Created by IF on 14/12/8.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "HeadView.h"
#import "FriendGroup.h"

@interface HeadView () <UIActionSheetDelegate, UIAlertViewDelegate>
{
	UIButton *_bgButton;
	UILabel *_numLabel;
	BOOL isDelete;
}
@end

@implementation HeadView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressWithFriendGroup:)];
		[self addGestureRecognizer:longPress];
		[self initWithReuseIdentifier:self];
	}
	return self;
}

- (void)initWithReuseIdentifier:(HeadView *)headView {
	headView.backgroundColor = [UIColor whiteColor];
	UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[bgButton setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg"] forState:UIControlStateNormal];
	[bgButton setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg_highlighted"] forState:UIControlStateHighlighted];
	[bgButton setImage:[UIImage imageNamed:@"buddy_header_arrow"] forState:UIControlStateNormal];
	[bgButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	bgButton.imageView.contentMode = UIViewContentModeCenter;
	bgButton.imageView.clipsToBounds = NO;
	bgButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	bgButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	bgButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	[bgButton addTarget:self action:@selector(headBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[headView addSubview:bgButton];
	_bgButton = bgButton;

	UILabel *numLabel = [[UILabel alloc] init];
	numLabel.textAlignment = NSTextAlignmentRight;
	[headView addSubview:numLabel];
	_numLabel = numLabel;
}

- (void)headBtnClick {
	_friendGroup.opened = !_friendGroup.isOpened;
	if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
		[_delegate clickHeadView];
	}
}

- (void)setFriendGroup:(FriendGroup *)friendGroup {
	_friendGroup = friendGroup;

	[_bgButton setTitle:friendGroup.name forState:UIControlStateNormal];
	_numLabel.text = [NSString stringWithFormat:@"%d", /*friendGroup.online,*/ friendGroup.friends.count];
}

- (void)didMoveToSuperview {
	_bgButton.imageView.transform = _friendGroup.isOpened ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformMakeRotation(0);
}

- (void)layoutSubviews {
	[super layoutSubviews];

	_bgButton.frame = self.bounds;
	_numLabel.frame = CGRectMake(self.frame.size.width - 70, 0, 60, self.frame.size.height);
}

- (void)handleLongPressWithFriendGroup:(UILongPressGestureRecognizer *)longPressgestureRecognizer {
	if (longPressgestureRecognizer.state == UIGestureRecognizerStateEnded) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Or Update Group" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Update Group", @"Delete Group", nil];
		[actionSheet showInView:self];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog(@"%@", _friendGroup.Id);
		isDelete = FALSE;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Group" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
		alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alertView show];
	}
	else if (buttonIndex == 1) {
		NSLog(@"%@", _friendGroup.Id);
		isDelete = TRUE;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Group" message:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
		[alertView show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		if (!isDelete) {//不是删除组而是更新组
			_friendGroup.name = [alertView textFieldAtIndex:0].text;
			ASIHTTPRequest *updateGroupsRequest = [t_Network httpPostValue:@{ @"tid": _friendGroup.Id, @"name":_friendGroup.name }.mutableCopy Url:anyTime_FriendTeam Delegate:nil Tag:anyTime_FriendTeam_tag];
			__block ASIHTTPRequest *updateGroupsReq = updateGroupsRequest;
			[updateGroupsRequest setCompletionBlock: ^{//请求成功
			    NSString *responseStr = [updateGroupsReq responseString];
			    NSLog(@"%@", responseStr);
			    id objGroup = [responseStr objectFromJSONString];
			    if ([objGroup isKindOfClass:[NSDictionary class]]) {
			        NSString *statusCode = [objGroup objectForKey:@"statusCode"];
			        if ([statusCode isEqualToString:@"1"]) {
			            [MBProgressHUD showSuccess:@"Update Success"];
			            if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
			                [_delegate clickHeadView];
						}
					}
				}
			}];

			[updateGroupsRequest setFailedBlock: ^{//请求失败
			    NSLog(@"%@", [updateGroupsReq responseString]);
			}];
			[updateGroupsRequest startAsynchronous];
		}
		else {//删除组
			if ([@"1" isEqualToString:_friendGroup.defaultTeam]) {
				[MBProgressHUD showError:@"Default group cannot be deleted!"];
				return;
			}
			ASIHTTPRequest *deleteGroupsRequest = [t_Network httpGet:@{ @"tid": _friendGroup.Id }.mutableCopy Url:anyTime_DeleteFTeam Delegate:nil Tag:anyTime_DeleteFTeam_tag];
			__block ASIHTTPRequest *delGroupsRequest = deleteGroupsRequest;
			[deleteGroupsRequest setCompletionBlock: ^{//请求成功
			    NSString *responseStr = [delGroupsRequest responseString];
			    NSLog(@"%@", responseStr);
			    id objGroup = [responseStr objectFromJSONString];
			    if ([objGroup isKindOfClass:[NSDictionary class]]) {
			        NSString *statusCode = [objGroup objectForKey:@"statusCode"];
			        if ([statusCode isEqualToString:@"1"]) {
			            [MBProgressHUD showSuccess:@"Delete Success"];
					}
				}
			    if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
			        [_delegate clickHeadView];
				}
			}];

			[deleteGroupsRequest setFailedBlock: ^{//请求失败
			    NSLog(@"%@", [delGroupsRequest responseString]);
			}];
			[deleteGroupsRequest startAsynchronous];
		}
	}
}

@end
