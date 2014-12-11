//
//  LPPopupListView.m
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Luka Penger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPPopupListView.h"


#define navigationBarHeight 44.0f
#define separatorLineHeight 1.0f
#define closeButtonWidth 44.0f
#define navigationBarTitlePadding 12.0f
#define animationsDuration 0.25f


@interface LPPopupListView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, strong) NSString *navigationBarTitle;
@property (nonatomic, assign) BOOL isMultipleSelection;

@end


@implementation LPPopupListView

static BOOL isShown = false;

#pragma mark - Lifecycle

- (id)initWithTitle:(NSString *)title list:(NSArray *)list selectedIndexes:(NSIndexSet *)selectedList point:(CGPoint)point size:(CGSize)size multipleSelection:(BOOL)multipleSelection
{
    CGRect frame = CGRectMake(point.x, point.y,size.width,size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.cellHighlightColor = [UIColor colorWithRed:(0.0/255.0) green:(60.0/255.0) blue:(127.0/255.0) alpha:0.5f];
        
        self.navigationBarTitle = title;
        self.arrayList = [NSArray arrayWithArray:list];
        self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedList];
        self.isMultipleSelection = multipleSelection;

        self.navigationBarView = [[UIView alloc] init];
        self.navigationBarView.backgroundColor = blueColor;
        [self addSubview:self.navigationBarView];

        self.separatorLineView = [[UIView alloc] init];
        self.separatorLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.separatorLineView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = self.navigationBarTitle;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.navigationBarView addSubview:self.titleLabel];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:self.closeButton];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = shadowPath.CGPath;
    
    self.navigationBarView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, navigationBarHeight);
    
    self.separatorLineView.frame = CGRectMake(0.0f, self.navigationBarView.frame.size.height, self.frame.size.width, separatorLineHeight);
    
    self.closeButton.frame = CGRectMake((self.navigationBarView.frame.size.width-closeButtonWidth), 0.0f, closeButtonWidth, self.navigationBarView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake(navigationBarTitlePadding, 0.0f, (self.navigationBarView.frame.size.width-closeButtonWidth-(navigationBarTitlePadding * 2)), navigationBarHeight);
    
    self.tableView.frame = CGRectMake(0.0f, (navigationBarHeight + separatorLineHeight), self.frame.size.width, (self.frame.size.height-(navigationBarHeight + separatorLineHeight)));
    
    
    if ([self.arrayList count]<=0) {
        __block ASIHTTPRequest *request = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:nil Tag:anyTime_GetFTlist_tag];
        [request setCompletionBlock:^{
            NSString *responeStr = [request responseString];
            NSLog(@"%@",[request responseString]);
            id groupObj = [responeStr objectFromJSONString];
            NSMutableArray *fgArray = [NSMutableArray array];
            if ([groupObj isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode = [groupObj objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    NSArray *groupArr = [groupObj objectForKey:@"data"];
                    for (NSDictionary *dic in groupArr) {
                        FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
                        [fgArray addObject:friendGroup];
                    }
                }
            }
            [request setFailedBlock:^{
                NSLog(@"%@",[request error]);
                [KVNProgress showError];
            }];
            self.arrayList = fgArray;
            [self.tableView reloadData];
        }];
        [request startAsynchronous];
    }
}

- (void)closeButtonClicked:(id)sender
{
    [self hideAnimated:self.closeAnimated];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LPPopupListViewCell";
    
    LPPopupListViewCell *cell = [[LPPopupListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.highlightColor = self.cellHighlightColor;
    FriendGroup *frG= [self.arrayList objectAtIndex:indexPath.row];
    cell.textLabel.text = frG.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:indexPath.row]) {
            cell.rightImageView.image = [UIImage imageNamed:@"checkMark"];
        } else {
            cell.rightImageView.image = nil;
        }
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:indexPath.row]) {
            [self.selectedIndexes removeIndex:indexPath.row];
        } else {
            [self.selectedIndexes addIndex:indexPath.row];
        }

        [self.tableView reloadData];
    } else {
        isShown = false;
        ////用户选择的组   传递一个是indexPath.row 索引
        if ([self.delegate respondsToSelector:@selector(popupListView:didSelectIndex:)]) {
            [self.delegate popupListView:self didSelectIndex:indexPath.row];
        }
        //用户选择的组  传递一个FriendGroup对象
        if ([self.delegate respondsToSelector:@selector(popupListView:didSelectFriendGroup:)]) {
            [self.delegate popupListView:self didSelectFriendGroup:self.arrayList[indexPath.row]];
        }
        [self hideAnimated:self.closeAnimated];
    }
}

#pragma mark - Instance methods

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    if(!isShown) {
        isShown = true;
        self.closeAnimated = animated;
        
        if(animated) {
            self.alpha = 0.0f;
            [view addSubview:self];
            
            [UIView animateWithDuration:animationsDuration animations:^{
                self.alpha = 1.0f;
            }];
        } else {
            [view addSubview:self];
        }
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:animationsDuration animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            isShown = false;
            
            if (self.isMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                    [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
                }
            }
            
            [self removeFromSuperview];
        }];
    } else {
        isShown = false;
        
        if (self.isMultipleSelection) {
            if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
            }
        }
        
        [self removeFromSuperview];
    }
}

@end
