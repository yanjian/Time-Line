//
//  MemberListViewController.m
//  Time-Line
//
//  Created by IF on 14/12/31.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "MemberListViewController.h"
#import "FriendInfoTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface MemberListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame=CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    
    
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, naviHigth)];
    rview.backgroundColor = blueColor;
   
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightBtn.frame = CGRectMake(15, 30, 21, 25);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(cancelFriendsView) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:rightBtn];
    

    UILabel * titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 30, 180, 30)];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.text = [NSString stringWithFormat:@"Friends List"];
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [rview addSubview:titlelabel];
    

    [self.view addSubview:rview];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, naviHigth, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc] init];
    [self.view  addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.memberArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellMemberId";
    FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = (FriendInfoTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
        //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *memberDic = [self.memberArr objectAtIndex:indexPath.row];
    
    cell.nickName.text =[memberDic objectForKey:@"name"];

    NSString *imgPath = [memberDic objectForKey:@"imgBig"];
    if (imgPath) {
        imgPath=[imgPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
    NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,imgPath]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];

    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancelFriendsView{
    [self dismissViewControllerAnimated:YES completion:nil];

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
