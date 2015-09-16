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

    UIView       *  datePickerView ;
    NSString     *  coorName;
    NSDictionary *  coorDic;//坐标点
    NSMutableArray * selectFriendArr ;
    
    ActiveDataMode * activeDataMode;
    
    NSDate * dueVoteDate ;
}

@property (nonatomic,retain) UIPopoverController *popover;

@property (nonatomic,assign) BOOL isClickDueDateVote ;
@property (nonatomic,retain) UIButton *leftBtn ;
@property (nonatomic,retain) UIButton *rightBtn ;
@property (nonatomic,retain) UITextField  *titleFiled ;
@property (nonatomic,retain) UITextField  *descFiled ;
@property (nonatomic,retain) MKMapView    *vMap;

@end

@implementation AddNewActiveViewController
@synthesize addNewActiveTableView  ;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event Details";
 //   [self colorWithNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
    self.addNewActiveTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    
    activeDataMode = [[ActiveDataMode alloc] init];//开始初始化一个
    
    if (self.isEdit) {
        selectFriendArr = @[].mutableCopy ;
        if ( self.activeEvent.location  &&  ![self.activeEvent.location isEqualToString:@""] ) {
            NSDictionary * locatonDic = [self.activeEvent.location objectFromJSONString];
            coorDic = @{LATITUDE:[locatonDic objectForKey:@"latitude"],LONGITUDE:[locatonDic objectForKey:@"longitude"]};
            coorName = [locatonDic objectForKey:@"location"] ;
        }
    }
    
    // [self createVariousView] ;
    //[self createDatePicker];
    
}
-(UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
        [_leftBtn setTag:1];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
        [_leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _leftBtn ;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
         _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [_rightBtn setTag:2];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_right"] forState:UIControlStateNormal] ;
        [_rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _rightBtn ;
}


-(UITextField *)titleFiled{
    if (!_titleFiled) {
        _titleFiled = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, kScreen_Width-30, 64)];
        _titleFiled.delegate = self;
        _titleFiled.tag = 3;
        _titleFiled.font = [UIFont boldSystemFontOfSize:20.0f];
        _titleFiled.textAlignment=NSTextAlignmentCenter;
        [_titleFiled setBorderStyle:UITextBorderStyleNone];
        _titleFiled.returnKeyType = UIReturnKeyDone ;
    }
    return _titleFiled ;
}

-(UITextField *)descFiled{
    //活动描述
    if (!_descFiled) {
        _descFiled=[[UITextField alloc]initWithFrame:CGRectMake(15, 0, kScreen_Width-30, 64)];
        _descFiled.delegate = self;
        _descFiled.tag = 4;
        _descFiled.font=[UIFont boldSystemFontOfSize:15.0f];
        _descFiled.returnKeyType = UIReturnKeyDone ;
        [_descFiled setBorderStyle:UITextBorderStyleNone];

    }
    return _descFiled ;
}


-(MKMapView *)vMap{
    if (!_vMap) {
        _vMap = [[MKMapView alloc] initWithFrame:CGRectMake(10, 0,kScreen_Width-20, 160)];
        _vMap.delegate = self;
        _vMap.camera.altitude = 170;
        _vMap.showsBuildings = YES;
        _vMap.zoomEnabled = NO ;
        _vMap.scrollEnabled = NO ;
    }
    return _vMap ;
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
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [self colorWithNavigationBar];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.titleFiled isFirstResponder]) {
        [self.titleFiled resignFirstResponder];
    }
    if ([self.descFiled isFirstResponder]) {
        [self.descFiled resignFirstResponder];
       
    }
     addNewActiveTableView.frame = CGRectMake(0, 0, addNewActiveTableView.frame.size.width, addNewActiveTableView.frame.size.height);
    //[self docancel];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
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
    return 4;
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
            NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, self.activeEvent.img] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:_urlStr];
            
            [activeImgCell.activeImag sd_setImageWithURL:url placeholderImage:ResizeImage([UIImage imageNamed:@"go2_grey"], CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds))  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                UIImage *reSizeImg = ResizeImage(image,CGRectGetWidth(activeImgCell.activeImag.bounds), CGRectGetHeight(activeImgCell.activeImag.bounds));
                activeImgCell.activeImag.image = reSizeImg ;
            }];
        }
       
        [self addCellSeparator:160 cell:activeImgCell];
        return activeImgCell ;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:AddNewActiveCellId] ;
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AddNewActiveCellId];
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
            self.titleFiled.placeholder = @"Event Title";
            [self.titleFiled becomeFirstResponder];
            if(self.isEdit){//编辑数据
                self.titleFiled.text = self.activeEvent.title ;
            }
            [cell.contentView addSubview:self.titleFiled];
            
            [self addCellSeparator:64 cell:cell];
        }else if(indexPath.section == 2 && indexPath.row == 0){
            self.descFiled.placeholder = @"Description";
            if (self.isEdit) {//编辑数据
                self.descFiled.text = self.activeEvent.enventDesc ;
            }
            [cell.contentView addSubview:self.descFiled];
            
            [self addCellSeparator:64 cell:cell];
        }else if(indexPath.section == 3 && indexPath.row == 0){
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator ;
            cell.textLabel.text = @"Location:" ;
            if (self.isEdit) {//编辑数据
                   cell.detailTextLabel.text = coorName ;
            }else{
                   cell.detailTextLabel.text = coorName ;
            }
            
            [self addCellSeparator:64 cell:cell];
        }else if(indexPath.section == 3 && indexPath.row == 1){
            
            cell.accessoryType  = UITableViewCellAccessoryNone ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            
            self.vMap.centerCoordinate = CLLocationCoordinate2DMake([[coorDic objectForKey:LATITUDE] doubleValue], [[coorDic objectForKey:LONGITUDE] doubleValue]);
    
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = self.vMap.centerCoordinate;
            NSDictionary * locatonDic = [self.activeEvent.location objectFromJSONString];
            annotation.title = coorName == nil ? [locatonDic objectForKey:@"location"]:coorName;
            [self.vMap addAnnotation:annotation];
            [cell addSubview:self.vMap];
            
            [self addCellSeparator:160 cell:cell];
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
    [navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
    
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
            if (self.titleFiled.text && [@"" isEqualToString:self.titleFiled.text]) {
                [MBProgressHUD showError:@"You forget give to a cool name of the event"];
                return;
            }
            InviteesViewController * inviteesVC = [[InviteesViewController alloc] init];

            
            activeDataMode.activeTitle       = self.titleFiled.text ;
            activeDataMode.activeDesc        = self.descFiled.text ;
            activeDataMode.activeLocName     = coorName ;
            activeDataMode.activeCoordinate  = coorDic ;
           // activeDataMode.activeDueVoteDate = [datePicker date] ;
            activeDataMode.activeImg         = activeImgCell.activeImag.image ;
            inviteesVC.activeDataMode = activeDataMode ;
            inviteesVC.navStyleType = NavStyleType_LeftRightSame ;
            
            if(self.isEdit){
                activeDataMode.Id = self.activeEvent.Id ;
                [selectFriendArr removeAllObjects];
                for (NSDictionary *tmpDic in self.activeEvent.invitees) {
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

//添加分割线
-(void)addCellSeparator:(CGFloat) LocaltionY cell:(UITableViewCell *) cell{
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, LocaltionY-1, cell.frame.size.width -20, 1)];
    separator.backgroundColor = [UIColor colorWithHexString:@"eeecec"];
    [cell.contentView addSubview:separator];
}

@end
