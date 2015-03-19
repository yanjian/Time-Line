//
//  FriendAddTableViewController.m
//  Time-Line
//
//  Created by IF on 15/3/17.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "FriendAddTableViewController.h"
#import "UIColor+HexString.h"
#import "FriendSearchViewController.h"

@interface FriendAddTableViewController ()

@end

@implementation FriendAddTableViewController
@synthesize dataArr ;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add Friends" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToFriendsView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    
    dataArr = [NSMutableArray arrayWithObjects:@"By account/display name",@"Connect to Google+\n to add friends" ,@"Connect to Facebook \n to add friends",nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
    return dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 190 ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseId = @"reuseIdAdd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId ];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    }
    UILabel *contentLab = [[UILabel alloc] init] ;
    UIFont *tfont = [UIFont systemFontOfSize:17.f];
    contentLab.font = tfont;
    contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    contentLab.numberOfLines = 2;
    NSString *tmpStr = dataArr[indexPath.section];
    contentLab.text =  tmpStr;
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont, NSFontAttributeName, nil];
    
    CGSize actualsize = [tmpStr boundingRectWithSize:CGSizeMake(260, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    contentLab.frame = CGRectMake((kScreen_Width-300)/2, 75, 300, actualsize.height);
    [contentLab setTextAlignment:NSTextAlignmentCenter] ;
    
    contentLab.backgroundColor = [UIColor clearColor] ;
    [contentLab setTextColor:[UIColor whiteColor]];
    
    if (indexPath.section == 0){
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"6bbcff"];
    }else if(indexPath.section == 1) {
        cell.contentView.backgroundColor = [UIColor redColor];
    }else{
        cell.contentView.backgroundColor = blueColor;
    }
    [cell.contentView addSubview:contentLab];
    return cell;
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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES] ;
    if (indexPath.section == 0) {
        FriendSearchViewController * friendSearchVc = [[FriendSearchViewController alloc] init] ;
        [self.navigationController pushViewController:friendSearchVc animated:YES] ;
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


-(void)backToFriendsView{
    [self.navigationController popViewControllerAnimated:YES] ;
    
}

@end
