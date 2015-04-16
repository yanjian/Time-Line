//
//  InviteesJoinOrReplyTableViewController.m
//  Time-Line
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "InviteesJoinOrReplyTableViewController.h"
#import "SetFriendTableViewCell.h"
#import "MemberDataModel.h"
#import "UIImageView+WebCache.h"
@interface InviteesJoinOrReplyTableViewController (){
    NSMutableArray * joinAndNoJoinArr;
}


@end

@implementation InviteesJoinOrReplyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Invitees" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventSettingView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    
    joinAndNoJoinArr = @[].mutableCopy;
    
    NSMutableArray * joinArr = @[].mutableCopy;
    NSMutableArray * noJoinArr = @[].mutableCopy;
    NSMutableArray * noReplyArr = @[].mutableCopy;
    for (MemberDataModel *memberData in self.memberArr) {
        if ([memberData.join intValue] == 1) {
            [joinArr addObject:memberData];
        }else if ([memberData.join intValue] == 2){
            [noJoinArr addObject:memberData];
        }else{
            [noReplyArr addObject:memberData];
        }
    }
    if (joinArr.count>0) {
        [joinAndNoJoinArr addObject:joinArr];
    }if (noJoinArr.count>0) {
        [joinAndNoJoinArr addObject:noJoinArr];
    }if (noReplyArr.count>0) {
        [joinAndNoJoinArr addObject:noReplyArr];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return joinAndNoJoinArr.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *tmpDataArr =(NSArray *) joinAndNoJoinArr[section];
    for (MemberDataModel *memberData in tmpDataArr) {
        if ([memberData.join intValue] == 1) {
            return @"Join:";
        }else if ([memberData.join intValue] == 2){
            return @"Not joining:";
        }else{
            return @"No Reply:" ;
        }
        break ;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *tmpDataArr =(NSArray *) joinAndNoJoinArr[section];
    return tmpDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SetFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinAndNoJoinID"];
    if (!cell) {
        cell = (SetFriendTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SetFriendTableViewCell" owner:self options:nil] lastObject];
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageView.image =[UIImage imageNamed:@"selecte_friend_cycle"] ;
        cell.accessoryView = imageView ;
        imageView.center = cell.accessoryView.center ;
    }
    
    NSArray *joinAndNoJoin = joinAndNoJoinArr[indexPath.section];
    MemberDataModel * memberData = (MemberDataModel *) joinAndNoJoin[indexPath.row];
    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, memberData.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
    cell.nickName.text = memberData.nickname;
    cell.userNote.text = memberData.username;
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)backToEventSettingView:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

@end
