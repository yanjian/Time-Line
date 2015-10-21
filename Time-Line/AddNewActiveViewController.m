//
//  AddNewActiveViewController.m
//  Go2
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "AddNewActiveViewController.h"
//#import "InviteesViewController.h"
#import "ActiveImageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "camera.h"
#import "utilities.h"
#import "PECropViewController.h"
#import "LocationViewController.h"
#import "ActiveDataMode.h"
#import "utilities.h"
#import "UIColor+HexString.h"


#import "EventTitleAndDescCellTableViewCell.h"
#import "LocationTableViewCell.h"
#import "NewPurposeEventTimeViewController.h"
static  NSString * AddNewActiveCellId = @"AddNewActiveCellId" ;

@interface AddNewActiveViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,PECropViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,getlocationDelegate,MKMapViewDelegate>
{
    ActiveImageTableViewCell *  activeImgCell;

    UIView       *  datePickerView ;
    NSString     *  coorName;
    NSDictionary *  coorDic;//坐标点
    
    ActiveDataMode * activeDataMode;
    
    NSDate * dueVoteDate ;
}

@property (nonatomic,retain) UIPopoverController *popover;

@property (nonatomic,assign) BOOL isClickDueDateVote ;
@property (nonatomic,retain) UIButton *leftBtn ;
@property (nonatomic,retain) UIButton *rightBtn ;
@property (nonatomic,retain) UITextField  *titleFiled ;
@property (nonatomic,retain) UITextField  *descFiled ;



@property (nonatomic,retain) EventTitleAndDescCellTableViewCell * eventTitleAndDescCell;
@property (nonatomic,retain) UIImageView * eventImg;
@end

@implementation AddNewActiveViewController
@synthesize addNewActiveTableView  ;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event Details";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
    self.addNewActiveTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    
    activeDataMode = [[ActiveDataMode alloc] init];//开始初始化一个
    
    if (self.isEdit) {
        if ( self.activeEvent.location  &&  ![self.activeEvent.location isEqualToString:@""] ) {
            NSDictionary * locatonDic = [self.activeEvent.location objectFromJSONString];
            coorDic = @{LATITUDE:[locatonDic objectForKey:@"latitude"],LONGITUDE:[locatonDic objectForKey:@"longitude"]};
            coorName = [locatonDic objectForKey:@"location"] ;
        }
    }
    
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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    if (textField.becomeFirstResponder) {
//        [textField resignFirstResponder];
//    }
//    return  YES ;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.eventTitleAndDescCell.eventTitle isFirstResponder]) {
        [self.eventTitleAndDescCell.eventTitle resignFirstResponder];
    }
    if ([self.eventTitleAndDescCell.descriptionText isFirstResponder]) {
        [self.descFiled resignFirstResponder];
       
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 180.f ;
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        if (coorDic) {
            return 200.f ;
        }else{
           return 44.f;
        }
    }else{
        return 200.f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
         return 20.01f;
    }else{
         return 0.01f;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.eventTitleAndDescCell = [tableView dequeueReusableCellWithIdentifier:AddNewActiveCellId];
        if (!self.eventTitleAndDescCell) {
             self.eventTitleAndDescCell = (EventTitleAndDescCellTableViewCell *)[[[UINib nibWithNibName:@"EventTitleAndDescCellTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
         if (self.isEdit) { //编辑数据
             self.eventTitleAndDescCell.eventTitle.text = self.activeEvent.title ;
             self.eventTitleAndDescCell.descriptionText.text = self.activeEvent.enventDesc ;
         }
        
       return self.eventTitleAndDescCell;
    }else{

        LocationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LocationId"];
        if (!cell) {
            cell = (LocationTableViewCell *)[[[UINib nibWithNibName:@"LocationTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        }
        if(indexPath.section == 1 && indexPath.row == 0){
            cell.descLable.text = @"Localtion:" ;
            cell.decorativeIcon.image = [UIImage imageNamed:@"adress_Icon"];
            cell.selectContentLable.text = coorName==nil?@"None":coorName;
            if (coorDic) {
             [cell.commonShowView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                  [obj removeFromSuperview];
              }];
                
               MKMapView * _vMap = [[MKMapView alloc] initWithFrame: CGRectMake(0, 0, cell.commonShowView.frame.size.width, cell.commonShowView.frame.size.height+1) ];
                _vMap.delegate = self;
                _vMap.camera.altitude = 170;
                _vMap.showsBuildings = YES;
                _vMap.zoomEnabled = NO ;
                _vMap.scrollEnabled = NO ;
                
                _vMap.centerCoordinate = CLLocationCoordinate2DMake([[coorDic objectForKey:LATITUDE] doubleValue], [[coorDic objectForKey:LONGITUDE] doubleValue]);
    
                MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = _vMap.centerCoordinate;
                NSDictionary * locatonDic = [self.activeEvent.location objectFromJSONString];
                annotation.title = coorName == nil ? [locatonDic objectForKey:@"location"]:coorName;
                [_vMap addAnnotation:annotation];
                [cell.commonShowView addSubview:_vMap];
                [_vMap mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.commonShowView).with.offset(0);
                    make.left.equalTo(cell.commonShowView).with.offset(0);
                    make.bottom.equalTo(cell.commonShowView).with.offset(-0);
                    make.right.equalTo(cell.commonShowView).with.offset(-0);
                }];

           }
        }else if(indexPath.section == 2 && indexPath.row == 0){
            cell.descLable.text = @"Event picture" ;
            cell.decorativeIcon.image = [UIImage imageNamed:@"ic-Picture"];
           
            [cell.commonShowView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            
            self.eventImg = [[UIImageView alloc] init];
            self.eventImg.frame = CGRectMake(0, 0, cell.commonShowView.frame.size.width, cell.commonShowView.frame.size.height+1);
            
            if (self.isEdit) { //编辑数据
                NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, self.activeEvent.img] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:_urlStr];
    
                [self.eventImg sd_setImageWithURL:url placeholderImage:ResizeImage([UIImage imageNamed:@"go2_grey"], CGRectGetWidth(self.eventImg.bounds), CGRectGetHeight(self.eventImg.bounds))  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    UIImage *reSizeImg = ResizeImage(image,CGRectGetWidth(self.eventImg.bounds), CGRectGetHeight(self.eventImg.bounds));
                    self.eventImg.image = reSizeImg ;
                }];
            }else{
                self.eventImg.image = [UIImage imageNamed:@"listdownload.jpg"];
            }
            [cell.commonShowView addSubview:self.eventImg];
            [self.eventImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.commonShowView).with.offset(0);
                make.left.equalTo(cell.commonShowView).with.offset(0);
                make.bottom.equalTo(cell.commonShowView).with.offset(-0);
                make.right.equalTo(cell.commonShowView).with.offset(-0);
            }];
            
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:nil
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"Photo Album", nil];
//        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//            [actionSheet addButtonWithTitle:@"Camera"];
//        }
//        
//        [actionSheet addButtonWithTitle:@"Cancel"];
//         actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
//        [actionSheet showInView:self.view];
    }else if(indexPath.section==1 && indexPath.row == 0){
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
            if (!self.eventTitleAndDescCell.eventTitle.text || [@"" isEqualToString:self.eventTitleAndDescCell.eventTitle.text]) {
                [MBProgressHUD showError:@"You forget give to a cool name of the event"];
                return;
            }
            NewPurposeEventTimeViewController * purposeEventVC = [[NewPurposeEventTimeViewController alloc] init];

            activeDataMode.activeTitle       = self.eventTitleAndDescCell.eventTitle.text ;
            activeDataMode.activeDesc        =self.eventTitleAndDescCell.descriptionText.text ;
            activeDataMode.activeLocName     = coorName ;
            activeDataMode.activeCoordinate  = coorDic ;
            activeDataMode.activeImg         = self.eventImg.image ;
            purposeEventVC.activeDataMode = activeDataMode ;
          
            
            if(self.isEdit){
                activeDataMode.Id = self.activeEvent.Id ;
                purposeEventVC.isEdit = self.isEdit ;
                purposeEventVC.activeEvent = self.activeEvent ;
            }
            [self.navigationController pushViewController:purposeEventVC animated:YES];
        }break;
            
        default:
            NSLog(@".........<<<<<<<>>>>>>>>>click other<<<<<<<<<>>>>>>>>>........");
            break;
    }
   
}


//添加分割线
-(void)addCellSeparator:(CGFloat) LocaltionY cell:(UITableViewCell *) cell{
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, LocaltionY-1, cell.frame.size.width -20, 1)];
    separator.backgroundColor = [UIColor colorWithHexString:@"eeecec"];
    [cell.contentView addSubview:separator];
}

@end
