//
//  SetingViewController.m
//  Time-Line
//
//  Created by IF on 14-10-10.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "SetingViewController.h"

@interface SetingViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SetingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.
    CGRect setTableFrame=CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    _setingTableView=[[UITableView alloc] initWithFrame:setTableFrame style:UITableViewStylePlain];
    [_setingTableView setBackgroundColor:[UIColor whiteColor]];
    _setingTableView.dataSource=self;
    _setingTableView.delegate=self;
    [self.view addSubview:_setingTableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier=@"cellSetIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
