//
//  UserInfoTableViewController.m
//  Time-Line
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "camera.h"
#import "utilities.h"
#import "UIImageView+WebCache.h"


#define  SMALL @"small"
#define  BIG   @"big"

@interface UserInfoTableViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate>{
    UIActionSheet *action;
    BOOL isSelectSex;
    BOOL isSelectHeadImg;
    BOOL isChangImg;
}
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (nonatomic,strong) NSMutableArray *userFixationArr;
@property (weak, nonatomic) IBOutlet UITextField *filedNickName;
@property (nonatomic,strong) UserInfo *userInfo;
@end

@implementation UserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.userInfo=[UserInfo currUserInfo];
    self.filedNickName.delegate=self;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Profile";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    
    self.navigationItem.hidesBackButton=YES;
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftBtn.frame=CGRectMake(0, 2, 21, 25);
    [leftBtn addTarget:self action:@selector(profileTobackSetingView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    
    
    [self.viewHeader addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    self.tableView.tableHeaderView = self.viewHeader;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,self.userInfo.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",_urlStr);
    NSURL *url=[NSURL URLWithString:_urlStr];
    [self.imageUser sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
    self.imageUser.layer.masksToBounds = YES;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.userFixationArr=@[@"Account",@"Phone",@"Gender"].mutableCopy;
    self.filedNickName.text=self.userInfo.nickName;
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!isSelectHeadImg) {
        ASIHTTPRequest *userRequest=[t_Network httpGet:@{@"tel":(self.userInfo.phone==nil?@"":self.userInfo.phone),@"name":(self.userInfo.nickName==nil?@"":self.userInfo.nickName),@"gender":@(self.userInfo.gender)}.mutableCopy Url:UserInfo_UpdateUserInfo Delegate:nil Tag:UserInfo_UpdateUserInfo_tag ];
        __block  ASIHTTPRequest *request = userRequest ;
        [userRequest setCompletionBlock:^{
            NSLog(@"数据更新成功：%@",[request responseString]);
        }];
        
        [userRequest setFailedBlock:^{
            NSLog(@"请求失败：%@",[request responseString]);
        }];
        [userRequest startAsynchronous];
        if (isChangImg) {//上传头像
            NSURL *url=[NSURL URLWithString:  [UserInfo_UploadImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            ASIFormDataRequest *uploadImageRequest=[ASIFormDataRequest requestWithURL:url] ;
            NSData *data = UIImagePNGRepresentation(self.imageUser.image);
            NSMutableData *imageData = [NSMutableData dataWithData:data];
            [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
            [uploadImageRequest setRequestMethod:@"POST"];
            [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
            //[uploadImageRequest setPostValue:photoDescribe forKey:@"photoContent"];
            NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
            
            [uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg",tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
            [uploadImageRequest setTag:UserInfo_UploadImg_tag];
            __block ASIFormDataRequest *uploadRequest = uploadImageRequest ;
            [uploadImageRequest setCompletionBlock:^{
                NSString * responseStr = [uploadRequest responseString];
                NSLog(@"数据更新成功：%@",responseStr);
                id obj = [responseStr objectFromJSONString];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary * tmpDic = (NSDictionary *)obj;
                    int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
                    if (statusCode==1) {
                        NSDictionary *dicData= [tmpDic objectForKey:@"data"];
                        NSString *smallPath = [dicData objectForKey:SMALL];
                        if (smallPath) {
                            self.userInfo.imgUrlSmall=[smallPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                        }
                        NSString *bigPath = [dicData objectForKey:BIG];
                        if (bigPath) {
                            self.userInfo.imgUrl = [bigPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                        }

                    }
                    
                }
            }];
            
            [uploadImageRequest setFailedBlock:^{
                NSLog(@"请求失败：%@",[uploadRequest responseString]);
            }];
            
            [uploadImageRequest startAsynchronous];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.userFixationArr.count;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"%@",textField.text)
    self.userInfo.nickName=textField.text;
}



-(void)dismissKeyboard{
    [self.view endEditing:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *userInforCell=@"userInfoCellId";
    UITableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:userInforCell];
    if (!userCell) {
        userCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userInforCell];
    }
    userCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    userCell.textLabel.text=self.userFixationArr[indexPath.row];
    if (indexPath.row==0) {
        
        userCell.detailTextLabel.text=self.userInfo.username;
    }else if (indexPath.row==1){
        userCell.detailTextLabel.text=self.userInfo.phone;
    }else if (indexPath.row==2){
        userCell.detailTextLabel.text= self.userInfo.gender==0?@"Female":@"Male";
    }
    
    return userCell;
}
#pragma mark -用户点击的是用户头像执行的方法
- (IBAction)accountPhoto:(UIButton *)sender {
    isSelectSex=NO;//不是选择的性别
    [self dismissKeyboard];
    action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo", nil];
    [action showInView:self.view];
}

#pragma mark -选择完相片后回调的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isSelectHeadImg=NO;
    isChangImg=YES;
    UIImage *image = info[UIImagePickerControllerEditedImage];

    if (image.size.width > 140){
        image = ResizeImage(image, 140, 140);
    }
    self.imageUser.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark -该方法是UIActionsheet的回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%i",buttonIndex);
    if (buttonIndex==0) {
        if (isSelectSex) {
            self.userInfo.gender=gender_woman;
        }else{
            isSelectHeadImg=YES;
           ShouldStartCamera(self,YES);
        }
    }else if(buttonIndex==1){
        if (isSelectSex) {
            self.userInfo.gender=gender_man;
        }else{
             isSelectHeadImg=YES;
             ShouldStartPhotoLibrary(self,YES);
        }
    }
   [self.tableView reloadData];
}



-(void) profileTobackSetingView{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -用户选择的行 Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissKeyboard];
    if (indexPath.row==1) {
        UIAlertView *textPhone=[[UIAlertView alloc] initWithTitle:@"Enter Phone" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        textPhone.delegate=self;
        textPhone.alertViewStyle=UIAlertViewStylePlainTextInput;
        [textPhone show];
    }else if (indexPath.row==2) {
        isSelectSex=YES;
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Female",@"Male", nil];
        [action showInView:self.view];
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        self.userInfo.phone = [alertView textFieldAtIndex:0].text;
        [self.tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
