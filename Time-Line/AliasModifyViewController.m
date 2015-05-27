//
//  AliasModifyViewController.m
//  Go2
//
//  Created by IF on 15/1/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "AliasModifyViewController.h"

@interface AliasModifyViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *aliasTable;

@property (retain, nonatomic) IBOutlet UITextField *aliasText;

@end

@implementation AliasModifyViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Alias Modify";

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(aliasTouchUpInside:) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBtn setTag:2];
	[rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_blueTick"] forState:UIControlStateNormal];
	[rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
	[rightBtn addTarget:self action:@selector(aliasTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    self.aliasText = [[UITextField alloc ] initWithFrame:CGRectMake(10, 0, kScreen_Width-10, 44)];
    self.aliasText.placeholder = @"Alias" ;
    self.aliasText.clearButtonMode = UITextFieldViewModeWhileEditing ;
	if (self.alias && ![self.alias isEqualToString:@""]) {
		[self.aliasText setText:self.alias];
	}
	[self.aliasText becomeFirstResponder];
    
    [self.aliasTable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFirstResponder:)]];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * aliasId =  @"aliasIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:aliasId] ;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aliasId];
    }
    [cell.contentView addSubview:self.aliasText];
    
    return cell ;
}




-(void)cancelFirstResponder:(UIGestureRecognizer *) gestureRecognizer {
    if (self.aliasText.becomeFirstResponder) {
            [self.aliasText resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)aliasTouchUpInside:(UIButton *)sender {
	switch (sender.tag) {
		case 1: {
			[self.navigationController popViewControllerAnimated:YES];
		} break;

		case 2: {
			NSString *aliasName = [self.aliasText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (!self.aliasText.text || [@"" isEqualToString:aliasName]) {
				[MBProgressHUD showError:@"Please enter an alias"];
				return;
			}

			ASIHTTPRequest *request = [t_Network httpGet:@{ @"fid":self.fid, @"name":aliasName }.mutableCopy Url:anyTime_UpdateFriendNickName Delegate:nil Tag:anyTime_UpdateFriendNickName_tag];
			__block ASIHTTPRequest *aliasRequest = request;
			[request setCompletionBlock: ^{
			    NSString *responseStr = [aliasRequest responseString];
			    id objGroup = [responseStr objectFromJSONString];
			    if ([objGroup isKindOfClass:[NSDictionary class]]) {
			        NSString *statusCode = [objGroup objectForKey:@"statusCode"];
			        if ([statusCode isEqualToString:@"1"]) {
			            if (self.aliasModify) {
			                self.aliasModify(self, aliasName);
						}
					}
				}
			}];
			[request setFailedBlock: ^{
			    [MBProgressHUD showError:@"Network error!"];
			}];
			[request startAsynchronous];
		} break;

		default:
			break;
	}
}

@end
