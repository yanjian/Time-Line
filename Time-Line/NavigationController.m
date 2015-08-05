

#import "NavigationController.h"
#import "UIColor+HexString.h"

@interface NavigationController (){

}
@property (nonatomic,retain) UIView * statusView ;
@end
@implementation NavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationBar.barTintColor = RGB(39, 135, 237);
	//self.navigationBar.tintColor    =    ;
	self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.translucent = NO;
    [self.navigationBar addSubview:self.statusView] ;
    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    self.navigationBar.layer.shadowColor  = [UIColor blackColor].CGColor ;
    self.navigationBar.layer.shadowRadius = 2.0f;//阴影半径
    self.navigationBar.layer.shadowOpacity = .45f ;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent ;
}


-(UIView *)statusView{
    if(!_statusView){
        _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kScreen_Width, 20)];
        _statusView.backgroundColor = RGB(18, 105, 173) ;
    }
    return _statusView ;
}

@end
