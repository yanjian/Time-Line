

#import "NavigationController.h"
#import "UIColor+HexString.h"
@implementation NavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];

	//self.navigationBar.barTintColor = [UIColor colorWithHexString:@"31aaeb"];
	//self.navigationBar.tintColor = [UIColor whiteColor];
	//self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};

	self.navigationBar.translucent = NO;
}

@end
