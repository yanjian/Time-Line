//
//  BackGroundViewController.m
//  Go2
//
//  Created by connor on 14-4-21.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "BackGroundViewController.h"
@interface BackGroundViewController () {
	NSArray *imageArrays;
	UIScrollView *scroillview;
	UIView *drawview;
	UIBarButtonItem *cameraButton;
}

@end
@implementation BackGroundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
//    scroillview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+155)];
//    scroillview.contentSize=CGSizeMake(self.view.frame.size.width, 1300);
//    self.view.backgroundColor=[UIColor whiteColor];
//    imageArrays=[[NSArray alloc]initWithObjects:@"Random_02.jpg",@"Random_04.jpg",@"Random_06.jpg",@"Random_11.jpg",@"Random_12.jpg",@"Friends_01.jpg",@"Friends_02.jpg",@"Friends_03.jpg",@"Concert_01.jpg",@"Cycling_01.jpg",@"Exhibition_01.jpg",@"Hiking_02.jpg",@"Hiking_04.jpg",@"Call_01.jpg",@"Lecture_01.jpg",@"Movie_01.jpg",nil];
//    [self dreawButton];
//    [self.view addSubview:scroillview];
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
//    [leftBtn setFrame:CGRectMake(0, 2, 15, 20)];
//    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
//
//    cameraButton =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addheadimage)];
//
//    self.navigationItem.rightBarButtonItem = cameraButton;
//
//    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 140, 40)];
//    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.font = [UIFont boldSystemFontOfSize:22];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text =@"背景图片";
//    [titleView addSubview:titleLabel];
//    self.navigationItem.titleView = titleView;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    drawview=[[UIView alloc]initWithFrame:self.view.frame];

	// Do any additional setup after loading the view from its nib.
}

//-(void)disviewcontroller{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)dreawButton {
	CGFloat width = 150;
	CGFloat height = 150;
	CGFloat margin = 2;
	CGFloat startX = (self.view.frame.size.width - 2 * width -  1 * margin) * 0.5;
	CGFloat startY = 70;
	for (int i = 0; i < [imageArrays count]; i++) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[scroillview addSubview:button];
		// 计算位置
		int row = i / 2;
		int column = i % 2;
		CGFloat x = startX + column * (width + margin);
		CGFloat y = startY + row * (height + margin);
		button.frame = CGRectMake(x, y, width, height);
		UIImage *tempimage = [UIImage imageNamed:[imageArrays objectAtIndex:i]];
		tempimage = [[PublicMethodsViewController getPublicMethods] imageWithImage:tempimage scaleToSize:CGSizeMake(tempimage.size.width / 2, tempimage.size.height / 4)];
		[button setBackgroundImage:tempimage forState:UIControlStateNormal];
		// 事件监听
		button.tag = i;
		[button addTarget:self action:@selector(tapImage:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)tapImage:(UIButton *)button {
	[_detelegate getimage:[imageArrays objectAtIndex:button.tag]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)addheadimage {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
	                                                         delegate:self
	                                                cancelButtonTitle:nil
	                                           destructiveButtonTitle:nil
	                                                otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
	}

	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[actionSheet showFromBarButtonItem:cameraButton animated:YES];
	}
	else {
		[actionSheet showFromToolbar:self.navigationController.toolbar];
	}
}

- (void)showCamera {
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
	controller.sourceType = UIImagePickerControllerSourceTypeCamera;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
		}

		self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
		[self.popover presentPopoverFromBarButtonItem:cameraButton
		                     permittedArrowDirections:UIPopoverArrowDirectionAny
		                                     animated:YES];
	}
	else {
		[self presentViewController:controller animated:YES completion:NULL];
	}
}

- (void)openPhotoAlbum {
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
	controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
		}

		self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
		[self.popover presentPopoverFromBarButtonItem:cameraButton
		                     permittedArrowDirections:UIPopoverArrowDirectionAny
		                                     animated:YES];
	}
	else {
		[self presentViewController:controller animated:YES completion:NULL];
	}
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
		[self openPhotoAlbum];
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
		[self showCamera];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
		}

		[self openEditor:image];
	}
	else {
		[picker dismissViewControllerAnimated:YES completion: ^{
		    [self openEditor:image];
		}];
	}
}

- (void)openEditor:(UIImage *)image {
	PECropViewController *controller = [[PECropViewController alloc] init];
	controller.delegate = self;
	controller.image = image;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	}

	[self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
	[controller dismissViewControllerAnimated:YES completion:NULL];
	NSData *Dataimage = UIImagePNGRepresentation(croppedImage);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"photo.png"];
	NSLog(@"%@", plistPath);
	[fileManager createFileAtPath:plistPath contents:Dataimage attributes:nil];
	[_detelegate getimage:plistPath];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
	[controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
