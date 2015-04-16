//
//  LocationViewController.m
//  Time-Line
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "LocationViewController.h"
#import "AutocompletionTableView.h"
@interface LocationViewController () <AutocompletionTableViewDelegate,ASIHTTPRequestDelegate>
    @property (nonatomic, strong) AutocompletionTableView *autoCompleter;//用于在文本框显示搜索到的数据
    @property (nonatomic, strong) NSDictionary *locationDic;//保存请求到的google坐标
@end

@implementation LocationViewController

@synthesize detelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.locationFiled inViewController:self withOptions:options];
    }
    return _autoCompleter;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Location" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    __block __weak LocationViewController *wself = self;
//    [[MMLocationManager shareLocation] getCity:^(NSString *cityString) {
//        [wself setLabelText:cityString];
//    }];
    AutocompletionTableView *autocompleView= self.autoCompleter;
    autocompleView.autocompletionDelegate=self;
    [self.locationFiled addTarget:autocompleView action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}


-(void)getTextField:(NSString *)fieldText locationDictionary:(NSDictionary *)location
{
   NSLog(@"%@",[location objectForKey:fieldText]) ;
    
    if (fieldText) {
        NSString *tempData=[location objectForKey:fieldText];
        if (tempData&&![@"" isEqualToString:tempData]) {
            NSMutableDictionary *paramDic=@{@"reference":tempData,
                                            @"sensor":@"true",
                                            @"key":GOOGLE_API_KEY }.mutableCopy;
            //请求google地址坐标
            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:GOOGLE_ADDRESS_LOCATION Delegate:self Tag:GOOGLE_ADDRESS_REQUEST_SEARCH_TAG];
            [request startAsynchronous];
        }
    }
}

/**
 *响应请求的结果：达到具体的坐标
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"请求到的坐标详细信息 = %@",[request responseString]);
    NSMutableDictionary *responesDic=[request.responseString objectFromJSONString];
    NSString *responesStatus=[responesDic objectForKey:@"status"];//发送请求返回的状态
    if ([GOOGLE_STATUS_OK isEqualToString:responesStatus] ) {
       NSDictionary *locdic= [[[responesDic objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"];
        NSLog(@"详细坐标：%@",locdic);
        self.locationDic=locdic;
    }
}

-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    if ([_locationFiled.text length]>0) {
        [detelegate getlocation:_locationFiled.text coordinate:self.locationDic];
    }

}


-(void)setLabelText:(NSString *)text
{
    _locationFiled.text = text;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
