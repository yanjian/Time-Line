/*

   Copyright 2012 Juan-Carlos Mendez (jcmendez@alum.mit.edu)

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

#import "JCMSegmentPageController.h"
#import "SloppySwiper.h"
#import "HomeViewController.h"

static const float TAB_BAR_HEIGHT = 0.f;//64.0f;
@implementation JCMSegmentPageController {
	UISegmentedControl *segmentedControl;
	UIView *contentContainerView;
	UIColor *tintColor;

	UIButton *_ZVbutton;//滑动试图左边view上的左边按钮
	UIButton *_rbutton;
	SloppySwiper *swiper;
}

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;


- (id)initWithTintColor:(UIColor *)color {
	self = [self init];
	if (self) {
		tintColor = color;
	}
	return self;
}

- (void)removeAllSegments {
	[segmentedControl removeAllSegments];
}

- (void)addSegments {
	NSUInteger index = 0;
	for (UIViewController *viewController in self.viewControllers) {
		[segmentedControl insertSegmentWithTitle:viewController.title atIndex:index animated:NO];
		++index;
	}
}

- (void)reloadTabButtons {
	[self removeAllSegments];
	[self addSegments];
	// TODO -- Do I need this???
	NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

- (void)layoutHeaderView {
	segmentedControl.frame = CGRectMake(0, 0, 220, 30);
}

/**
 * When the view loads, we set the header, and on it, the segmented control that will control
 * the page being displayed
 */
- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor whiteColor];
	CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, TAB_BAR_HEIGHT);

	// 右边xiew上返回button
	_rbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_rbutton.frame = CGRectMake(280, 30, 21, 25);
	[_rbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow1"] forState:UIControlStateNormal];
	[_rbutton addTarget:self action:@selector(setrbutton) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rbutton];

	//左边的按钮
	_ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_ZVbutton.frame = CGRectMake(0, 20, 45, 45);
	[_ZVbutton setBackgroundImage:[UIImage imageNamed:@"setting_default"] forState:UIControlStateNormal];
	[_ZVbutton addTarget:self action:@selector(setZVbutton) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_ZVbutton];

	CGRect segmentedControlRect = CGRectMake(0, 0, 220, 30);
	segmentedControl = [[UISegmentedControl alloc] initWithFrame:segmentedControlRect];
	segmentedControl.momentary = NO;
	[segmentedControl addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventValueChanged];
	if (tintColor) {
		[segmentedControl setTintColor:tintColor];
	}
	self.navigationItem.titleView = segmentedControl;

	rect.origin.y = TAB_BAR_HEIGHT;
	rect.size.height = self.view.bounds.size.height - TAB_BAR_HEIGHT;
	contentContainerView = [[UIView alloc] initWithFrame:rect];
	contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:contentContainerView];

	[self reloadTabButtons];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	contentContainerView = nil;
	segmentedControl = nil;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	//[self layoutHeaderView];
}

- (void)dealloc {
	_viewControllers = nil;
	_delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Only rotate if all child view controllers agree on the new orientation.
	for (UIViewController *viewController in self.viewControllers) {
		if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation])
			return NO;
	}
	return YES;
}

- (void)setViewControllers:(NSArray *)newViewControllers {
	NSAssert([newViewControllers count] >= 2, @"JCMSegmentPageController requires at least two view controllers");

	UIViewController *oldSelectedViewController = self.selectedViewController;

	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers) {
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}

	_viewControllers = [newViewControllers copy];

	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if (newIndex != NSNotFound)
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;

	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers) {
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}

	if ([self isViewLoaded])
		[self reloadTabButtons];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex {
	[self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
	NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");

	if ([self.delegate respondsToSelector:@selector(segmentPageController:shouldSelectViewController:atIndex:)]) {
		UIViewController *toViewController = [self.viewControllers objectAtIndex:newSelectedIndex];
		if (![self.delegate segmentPageController:self shouldSelectViewController:toViewController atIndex:newSelectedIndex])
			return;
	}

	if (![self isViewLoaded]) {
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex) {
		UIViewController *fromViewController = nil;
		UIViewController *toViewController = nil;

		NSUInteger oldSelectedIndex = _selectedIndex;
		_selectedIndex = newSelectedIndex;

		if (_selectedIndex != NSNotFound) {
			[segmentedControl setSelectedSegmentIndex:_selectedIndex];
			toViewController = self.selectedViewController;
		}

		if (toViewController == nil) { // don't animate
			[fromViewController.view removeFromSuperview];
		}
		else if (fromViewController == nil) { // don't animate
			toViewController.view.frame = contentContainerView.bounds;
			[contentContainerView addSubview:toViewController.view];

			if ([self.delegate respondsToSelector:@selector(segmentPageController:didSelectViewController:atIndex:)])
				[self.delegate segmentPageController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
		}
		else if (animated) {
			CGRect rect = contentContainerView.bounds;
			if (oldSelectedIndex < newSelectedIndex)
				rect.origin.x = rect.size.width;
			else
				rect.origin.x = -rect.size.width;

			toViewController.view.frame = rect;
			[self transitionFromViewController:fromViewController
			                  toViewController:toViewController
			                          duration:0.3
			                           options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
			                        animations: ^{
			    CGRect rect = fromViewController.view.frame;
			    if (oldSelectedIndex < newSelectedIndex)
					rect.origin.x = -rect.size.width;
			    else
					rect.origin.x = rect.size.width;

			    fromViewController.view.frame = rect;
			    toViewController.view.frame = contentContainerView.bounds;
			}
			                        completion: ^(BOOL finished) {
			    if ([self.delegate respondsToSelector:@selector(segmentPageController:didSelectViewController:atIndex:)])
					[self.delegate segmentPageController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
			}];
		}
		else {   // not animated
			[fromViewController.view removeFromSuperview];

			toViewController.view.frame = contentContainerView.bounds;
			[contentContainerView addSubview:toViewController.view];

			if ([self.delegate respondsToSelector:@selector(segmentPageController:didSelectViewController:atIndex:)])
				[self.delegate segmentPageController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
		}
	}
}

- (UIViewController *)selectedViewController {
	if (self.selectedIndex != NSNotFound)
		return [self.viewControllers objectAtIndex:self.selectedIndex];
	else
		return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController {
	[self setSelectedViewController:newSelectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated;
{
	NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
	if (index != NSNotFound)
		[self setSelectedIndex:index animated:animated];
}

- (void)tabButtonPressed:(UISegmentedControl *)sender {
	[self setSelectedIndex:sender.selectedSegmentIndex animated:YES];
}

- (void)setingViewControllerDelegate:(SetingViewController *)selfViewController {
	[UserInfo currUserInfo].loginStatus = UserLoginStatus_NO;  //设置为没有登录状态
	[USER_DEFAULT removeObjectForKey:CURRENTUSERINFO];
	[USER_DEFAULT synchronize];
	[selfViewController dismissViewControllerAnimated:YES completion:nil];
	for (UIViewController *viewController in self.navigationController.viewControllers) {
		if ([viewController isKindOfClass:[HomeViewController class]]) {
			[self.navigationController popToViewController:viewController animated:NO];
		}
	}
}

- (void)setZVbutton {
	/**另外一种导航滑动样式！
	   SetingViewController *setVC=[[SetingViewController alloc] init];
	   SetingsNavigationController *nc=[[SetingsNavigationController alloc] initWithRootViewController:setVC];
	   nc.navigationBar.translucent=NO;
	   nc.navigationBar.barTintColor=blueColor;
	   [self presentViewController:nc animated:YES completion:nil];
	   self.isRefreshUIData=NO;
	 */


	SetingViewController *setVC = [[SetingViewController alloc] init];
	setVC.delegate = self;
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:setVC];
	nc.navigationBar.translucent = NO;
	nc.navigationItem.hidesBackButton = YES;
	nc.navigationBar.barTintColor = blueColor;
	swiper = [[SloppySwiper alloc] initWithNavigationController:nc];
	nc.delegate = swiper;
	[self presentViewController:nc animated:YES completion:nil];
}

#pragma mark -－－ 所有点击事件
- (void)setrbutton {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
