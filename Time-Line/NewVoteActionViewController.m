//
//  NewVoteActionViewController.m
//  Time-Line
//
//  Created by IF on 14/12/22.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NewVoteActionViewController.h"
#import "PlaceholderTextView.h"

#define marginX 10

#define heightForRow 40
#define heightFooter 70

@interface NewVoteActionViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    PlaceholderTextView *_placeText;
    UITableView * _questionTable;
    
    CGRect frame ;
    int _questionCount;
    UIView * view ;
    
    NSInteger allowOption;
    
    UIScrollView * _scorllView;
    
    NSMutableArray *textValArr;
    NSMutableDictionary *textValDic;
}
@property (nonatomic , copy)   NSString * optionTitle;
@property (nonatomic , retain) NSArray  * optionArr;

@end

@implementation NewVoteActionViewController
@synthesize optionArr,optionTitle,isEdit,voteOptionDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"New Vote";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftBtn.frame=CGRectMake(0, 2, 21, 25);
    [leftBtn addTarget:self action:@selector(popViewControllerToActiveView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Tick"] forState:UIControlStateNormal];
    rightBtn.frame=CGRectMake(0, 2, 30, 25);
    [rightBtn addTarget:self action:@selector(saveNewVoteContext) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    optionTitle = [voteOptionDic objectForKey:@"title"];
    optionArr = [voteOptionDic objectForKey:@"optionList"];
    
    textValArr = [NSMutableArray arrayWithCapacity:0];
    textValDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    _scorllView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _scorllView.scrollEnabled=YES;
    _scorllView.delegate = self;
    _scorllView.contentSize =CGSizeMake(kScreen_Width, kScreen_Height+50);
    [self.view addSubview:_scorllView] ;
    
    frame = CGRectMake(marginX, marginX, kScreen_Width -marginX*2, 80);
    _placeText=[[PlaceholderTextView alloc] initWithFrame:frame];
    _placeText.font=[UIFont boldSystemFontOfSize:14];
    _placeText.placeholderFont=[UIFont boldSystemFontOfSize:13];
    _placeText.layer.borderWidth=0.5;
    _placeText.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [_scorllView addSubview:_placeText];

    if (isEdit) {
        _questionCount = optionArr.count ;
        _placeText.text = optionTitle ;
        for (NSUInteger i=0 ; i< _questionCount; i++) {
            [textValDic setValue:optionArr[i] forKey:@(i).stringValue];
        }
    }else{
        _questionCount = 2;
         _placeText.placeholder=@"Question...";
    }
    view = [[UIView alloc] initWithFrame:CGRectMake(marginX, frame.size.height+3*marginX+frame.origin.y, kScreen_Width -marginX*2, heightForRow*_questionCount+heightFooter+20)];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _questionTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height) style:UITableViewStylePlain];
    _questionTable.delegate=self;
    _questionTable.dataSource=self;
    _questionTable.bounces = NO;
    [view addSubview:_questionTable];
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, view.frame.size.width
                                                                   , heightFooter)];
    
    UILabel *flagLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 30, 30)];
    flagLab.text = @"➕";
    
    
    UIButton * addQuestionBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 2, footerView.frame.size.width-5, heightForRow)];
    [addQuestionBtn setTitle:@"Add an option..." forState:UIControlStateNormal] ;
    addQuestionBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [addQuestionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addQuestionBtn addTarget:self action:@selector(addAnOption:) forControlEvents:UIControlEventTouchUpInside];
    addQuestionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    UIButton *allowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [allowBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_cycle"] forState:UIControlStateNormal];
    [allowBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_tick"] forState:UIControlStateSelected];
    allowBtn.frame = CGRectMake(0, 45, 30, 30);
    [allowBtn addTarget:self action:@selector(allowAnyoneAddOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    if (isEdit) {
        allowBtn.selected = YES ;
        allowOption = 1;//表示允许成员添加时间
    }else{
        allowBtn.selected = NO ;
        allowOption = 0;//表示允许成员添加时间
    }
    
    UILabel * allowLab = [[UILabel alloc] initWithFrame:CGRectMake(35, heightForRow, kScreen_Width-2*50, heightForRow)];
    allowLab.text = @"Allow anyone to add options";
    [footerView addSubview:flagLab];
    [footerView addSubview:allowLab];
    [footerView addSubview:addQuestionBtn];
    [footerView addSubview:allowBtn];
    _questionTable.tableFooterView = footerView;
    
    [_scorllView addSubview:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledDidEndChanged:) name:UITextFieldTextDidEndEditingNotification object:nil];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  _questionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return heightForRow;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"questionId";
    UITableViewCell * cell   = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    for (UIView * sview in cell.contentView.subviews) {
        [sview removeFromSuperview];
    }
    UILabel *flagLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 30, 30)];
    flagLab.text = @"➕";
    flagLab.textAlignment = NSTextAlignmentCenter;
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(32, 2, 150, 30)];
    textField.placeholder = @"Enter An Question";
    NSLog(@"%d",indexPath.section);
    textField.tag = indexPath.section;
    textField.text = [[textValDic objectForKey:@(indexPath.section).stringValue] objectForKey:@"option"];
    [cell.contentView addSubview:flagLab ];
    [cell.contentView addSubview:textField ];
    return cell;
}



-(void)addAnOption:(UIButton *) sender{
    _questionCount++;
    view.frame=CGRectMake(marginX, frame.size.height+3*marginX+frame.origin.y, kScreen_Width -marginX*2, heightForRow*_questionCount+heightFooter);
    _questionTable.frame = CGRectMake(0, 0, kScreen_Width -marginX*2,  heightForRow*_questionCount+heightFooter+5);
    [_questionTable reloadData];

}


-(void)allowAnyoneAddOptions:(UIButton *)sender {
    if (sender.selected) {
        sender.selected=NO;
        allowOption = 0; //no
    }else{
        sender.selected=YES;
        allowOption=1;//表示允许成员添加时间
    }
    [_questionTable reloadData];
    
}

-(void)textFiledDidEndChanged:(NSNotification *) textFieldNot{
    UITextField *textF =(UITextField *) textFieldNot.object;
    if (textF.text&&![@""isEqualToString:textF.text]) {
         NSMutableDictionary *optionDic = [NSMutableDictionary dictionaryWithDictionary:[textValDic objectForKey:@(textF.tag).stringValue] ];
        if (optionDic && optionDic.count>0) {
            [optionDic removeObjectForKey:@"option"];
            [optionDic setObject:textF.text forKey:@"option"];
            [textValDic removeObjectForKey:@(textF.tag).stringValue];
            [textValDic setObject:optionDic forKey:@(textF.tag).stringValue];
        }else{
          [ textValDic removeObjectForKey:@(textF.tag).stringValue];
          [textValDic setObject:@{@"option":textF.text}.mutableCopy forKeyedSubscript:@(textF.tag).stringValue];
        }
    }
}


-(void)saveNewVoteContext{

    if (!_placeText.text||[@"" isEqualToString:_placeText.text]) {
        [KVNProgress showErrorWithStatus:@"Please Enter An Question!"];
        [_placeText becomeFirstResponder];
        return;
    }
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:0];
    [textValDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"%@ ===%@",key,obj);
        [tmpArr addObject:obj];
    }];
    

    if (self.delegate && [self.delegate respondsToSelector:@selector(newVoteActionViewController: mainQuestion: allowAddQuestion:childQuestion:optionId:isEdit:)]) {
        [self.delegate newVoteActionViewController:self mainQuestion:_placeText.text allowAddQuestion:allowOption childQuestion:tmpArr optionId:[voteOptionDic objectForKey:@"id"] isEdit:isEdit];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_placeText resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)popViewControllerToActiveView{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
