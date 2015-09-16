//
//  InviteesJoinOrReplyTableViewController.m
//  Go2
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "InviteesJoinOrReplyTableViewController.h"
#import "SetFriendTableViewCell.h"
#import "MemberDataModel.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"
@interface InviteesJoinOrReplyTableViewController (){
    NSMutableArray * joinAndNoJoinArr;
}


@end

@implementation InviteesJoinOrReplyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Invitees" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (self.isOpenModel) {
        [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
        [leftBtn setTag:1];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
    }else{
        [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [leftBtn setTag:2];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    }
    [leftBtn addTarget:self action:@selector(backToEventSettingView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    joinAndNoJoinArr = @[].mutableCopy;
    NSMutableArray * joinArr = @[].mutableCopy;
    NSMutableArray * noJoinArr = @[].mutableCopy;
    NSMutableArray * noReplyArr = @[].mutableCopy;
    
    for (MemberDataModel *memberData in self.memberArr) {
        if ([memberData.isJoining intValue] == 1) {
            [joinArr addObject:memberData];
        }else if ([memberData.isJoining intValue] == 2){
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
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
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
        if ([memberData.isJoining intValue] == 1) {
            return @"Join:";
        }else if ([memberData.isJoining intValue] == 2){
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
    }
    
    NSArray *joinAndNoJoin = joinAndNoJoinArr[indexPath.section];
    MemberDataModel * memberData = (MemberDataModel *) joinAndNoJoin[indexPath.row];
    
    NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP,[memberData.user objectForKey:@"thumbnail"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
    cell.nickName.text = [memberData.user objectForKey:@"nickname"];
    cell.userNote.text = [memberData.user objectForKey:@"username"];
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)backToEventSettingView:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 2:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

@end
