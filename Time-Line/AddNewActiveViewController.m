//
//  AddNewActiveViewController.m
//  Go2
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "AddNewActiveViewController.h"
#import "InviteesViewController.h"
#import "ActiveImageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "camera.h"
#import "utilities.h"
#import "PECropViewController.h"
#import "LocationViewController.h"
#import "ActiveDataMode.h"
#import "utilities.h"
#import "UIColor+HexString.h"
static  NSString * AddNewActiveCellId = @"AddNewActiveCellId" ;

@interface AddNewActiveViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,PECropViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,getlocationDelegate,MKMapViewDelegate>
{
    ActiveImageTableViewCell *  activeImgCell;
    UIDatePicker *  datePicker;
    UITextField  *  titleFiled ;
    UITextField  *  descFiled ;
    UIView       *  datePickerView ;
    NSString     *  coorName;
    NSDictionary *  coorDic;//坐标点
    NSMutableArray * selectFriendArr ;
    
    ActiveDataMode * activeDataMode;
    
    NSDate * dueVoteDate ;
}

@property (nonatomic,retain) UIPopoverController *popover;

@property (nonatomic,assign) BOOL isClickDueDateVote ;

@end

@implementation AddNewActiveViewController
@synthesize addNewActiveTableView  ;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event Details";
    [self colorWithNavigationBar];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
   
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_right"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
    
    activeDataMode = [[ActiveDataMode alloc] init];//开始初始化一个
    
    if (self.isEdit) {
        selectFriendArr = @[].mutableCopy ;
        if (self.activeEvent.coordinate && ![self.activeEvent.coordinate isEqualToString:@""]) {
            NSArray * coorArr = [self.activeEvent.coordinate componentsSeparatedByString:@";"];
            coorDic = @{LATITUDE:coorArr[0],LONGITUDE:coorArr[1]};
        }
    }
    
    [self createVariousView] ;
    [self createDatePicker];
    
}



-(void)createVariousView{
    //活动标题
    titleFiled=[[UITextField alloc]initWithFrame:CGRectMake(15, 0, kScreen_Width-30, 64)];
    titleFiled.delegate = self;
    titleFiled.tag = 3;
    titleFiled.font=[UIFont boldSystemFontOfSize:20.0f];
    titleFiled.textAlignment=NSTextAlignmentCenter;
    [titleFiled setBorderStyle:UITextBorderStyleNone];
    titleFiled.returnKeyType = UIReturnKeyDone ;
    
    //活动描述
    descFiled=[[UITextField alloc]initWithFrame:CGRectMake(15, 0, kScreen_Width-30, 64)];
    descFiled.delegate = self;
    descFiled.tag = 4;
    descFiled.font=[UIFont boldSystemFontOfSize:15.0f];
    descFiled.returnKeyType = UIReturnKeyDone ;
    [descFiled setBorderStyle:UITextBorderStyleNone];

    
}

- (void)createDatePicker

{
    datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 140)] ;
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style: UIBarButtonItemStyleDone
                                                                   target: self
                                                                   action: @selector(done)];
    
    UIBarButtonItem *leftButton  = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                            style: UIBarButtonItemStyleBordered
                                                                           target: self                                                                           action: @selector(docancel)];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                                                  target: nil
                                                                                  action: nil];
    
    
    
    NSArray *array = [[NSArray alloc] initWithObjects: leftButton,fixedButton, rightButton, nil];
    
    [toolBar setItems: array];
    
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    datePicker.datePickerMode = UIDatePickerModeDate ;
    if (!self.isEdit) {
        NSDate * nowDate = [NSDate new];
        dueVoteDate = [nowDate dateByAddingTimeInterval:7*24*60*60] ;//默认在当前时间上添加7天 ；
        datePicker.date = dueVoteDate ;
    }
    
    [datePickerView addSubview:toolBar];
    [datePickerView addSubview:datePicker];
    [self.view addSubview:datePickerView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self colorWithNavigationBar];
}

/**
 *配置NavigationBar的颜色，和字体的颜色
 */
-(void)colorWithNavigationBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.becomeFirstResponder) {
        [textField resignFirstResponder];
    }
    return  YES ;
}


-(void)done{
    NSDate *select = [datePicker date];
    dueVoteDate = select ;

    [addNewActiveTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    [self docancel];
}

- (void)docancel{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGPoint dateViewPoin =  datePickerView.center;
    dateViewPoin.y+=300;
    datePickerView.center = dateViewPoin ;
    addNewActiveTableView.frame = CGRectMake(0, 0, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
    [UIView commitAnimations];
    self.isClickDueDateVote = NO ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([titleFiled isFirstResponder]) {
        [titleFiled resignFirstResponder];
    }
    if ([descFiled isFirstResponder]) {
        [descFiled resignFirstResponder];
       
    }
     addNewActiveTableView.frame = CGRectMake(0, 0, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
    //[self docancel];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(self.isClickDueDateVote){
        [self docancel];
    }
    if (4 == textField.tag) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        if (coorDic) {
            addNewActiveTableView.frame = CGRectMake(0, -60, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
        }else{
           addNewActiveTableView.frame = CGRectMake(0, -20, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
          }
        [UIView commitAnimations];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (coorDic) {
        if (section == 3) {
            return 2 ;
        }
    }
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 160.f ;
    }else{
        if (coorDic) {
            if ( indexPath.section == 3 && indexPath.row == 1 ) {
                return 160.f;
            }
        }
        
        return 64.f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (!activeImgCell) {
             activeImgCell =(ActiveImageTableViewCell *)[[[UINib nibWithNibName:@"ActiveImageTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
        
        if (self.isEdit) { //编辑数据
            NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, self.activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:_urlStr];
            
            [activeImgCell.activeImag sd_setImageWithURL:url placeholderImage:ResizeImage([UIImage imageNamed:@"018.jpg"], CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds))  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                UIImage *reSizeImg = ResizeImage(image,CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds));
                activeImgCell.activeImag.image = reSizeImg ;
            }];
        }
        return activeImgCell ;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:AddNewActiveCellId] ;
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AddNewActiveCellId];
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
            titleFiled.placeholder = @"Event Title";
            [titleFiled becomeFirstResponder];
            if(self.isEdit){//编辑数据
                titleFiled.text = self.activeEvent.title ;
            }
            [cell.contentView addSubview:titleFiled];
        }else if(indexPath.section == 2 && indexPath.row == 0){
            descFiled.placeholder = @"Description";
            if (self.isEdit) {//编辑数据
                descFiled.text = self.activeEvent.note ;
            }
            [cell.contentView addSubview:descFiled];
        }else if(indexPath.section == 3 && indexPath.row == 0){
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator ;
            cell.textLabel.text = @"Location:" ;
            if (self.isEdit) {//编辑数据
                if(!coorName){
                   cell.detailTextLabel.text = self.activeEvent.location ;
                }else{
                    cell.detailTextLabel.text = coorName ;
                }
            }else{
                cell.detailTextLabel.text = coorName ;
            }
           
        }else if(indexPath.section == 3 && indexPath.row == 1){
            
            cell.accessoryType  = UITableViewCellAccessoryNone ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            MKMapView *vMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          kScreen_Width, 160)];

            vMap.delegate = self;
            vMap.centerCoordinate = CLLocationCoordinate2DMake([[coorDic objectForKey:LATITUDE] doubleValue], [[coorDic objectForKey:LONGITUDE] doubleValue]);
            vMap.camera.altitude = 170;
            // vMap.camera.pitch = 70;
            vMap.showsBuildings = YES;
            vMap.zoomEnabled = NO ;
            vMap.scrollEnabled = NO ;
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = vMap.centerCoordinate;
            annotation.title = coorName;
            [vMap addAnnotation:annotation];
            [cell addSubview:vMap];
        }else if(indexPath.section == 4 && indexPath.row == 0){
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator ;
            cell.textLabel.text = @"Due date to vote:" ;
            cell.detailTextLabel.textColor = [UIColor blackColor ];
            if (self.isEdit) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
                cell.detailTextLabel.text = [self stringFromNSDate:[dateFormatter dateFromString:self.activeEvent.voteEndTime]];
            }else{
                cell.detailTextLabel.text = [self stringFromNSDate:dueVoteDate];
            }
        }
        return cell ;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Photo Album", nil];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:@"Camera"];
        }
        
        [actionSheet addButtonWithTitle:@"Cancel"];
         actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        [actionSheet showInView:self.view];
    }else if(indexPath.section==3 && indexPath.row == 0){
        LocationViewController *locationView = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
        locationView.detelegate = self;
        [self.navigationController pushViewController:locationView animated:YES];
    }else if (indexPath.section==4 && indexPath.row ==0){
        if (!self.isClickDueDateVote){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            CGPoint dateViewPoin =  datePickerView.center;
            dateViewPoin.y-=300;
            datePickerView.center = dateViewPoin ;
            if (coorDic) {
                 addNewActiveTableView.frame = CGRectMake(0, -240, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
            }else{
                addNewActiveTableView.frame = CGRectMake(0, -150, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
            }
            [UIView commitAnimations];
            self.isClickDueDateVote = YES ;
        }
    }
}



-(void)getlocation:(NSString*) name coordinate:(NSDictionary *) coordinatesDic{
    coorName = name ;
    coorDic = coordinatesDic ;
    [addNewActiveTableView reloadData] ;
}


#pragma mark -该方法是UIActionsheet的回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
        [self openPhotoAlbum];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
        [self showCamera];
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
        [self.popover presentPopoverFromRect:self.view.frame inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark - Private methods

- (void)showCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromRect:self.view.frame inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = ResizeImage(image, kScreen_Width, kScreen_Width / 2);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
            [self openEditor:image];
        }
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
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake(0, length / 4, width, width / 2);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.barTintColor = blueColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    activeImgCell.activeImag.image  = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



-(void)backToEventView:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{//
             [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 2:{//open ---> viewController
            if (titleFiled.text && [@"" isEqualToString:titleFiled.text]) {
                [MBProgressHUD showError:@"You forget give to a cool name of the event"];
                return;
            }
            InviteesViewController * inviteesVC = [[InviteesViewController alloc] init];

            
            activeDataMode.activeTitle       = titleFiled.text ;
            activeDataMode.activeDesc        = descFiled.text ;
            activeDataMode.activeLocName     = coorName ;
            activeDataMode.activeCoordinate  = coorDic ;
            activeDataMode.activeDueVoteDate = [datePicker date] ;
            activeDataMode.activeImg         = activeImgCell.activeImag.image ;
            inviteesVC.activeDataMode = activeDataMode ;
            inviteesVC.navStyleType = NavStyleType_LeftRightSame ;
            
            if(self.isEdit){
                activeDataMode.Id = self.activeEvent.Id ;
                [selectFriendArr removeAllObjects];
                for (NSDictionary *tmpDic in self.activeEvent.member) {
                    [selectFriendArr addObject:[tmpDic objectForKey:@"uid"]];
                }
                inviteesVC.joinAllArr = selectFriendArr ;
                inviteesVC.isEdit = self.isEdit ;
                inviteesVC.activeEvent = self.activeEvent ;
            }

            [self.navigationController pushViewController:inviteesVC animated:YES];
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
   
}

-(NSString *)stringFromNSDate:(NSDate *) parmDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE d MMM"];
    return [dateFormatter stringFromDate:parmDate];
}

@end
