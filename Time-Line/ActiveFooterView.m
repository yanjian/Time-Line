//
//  ActiveFooterView.m
//  Time-Line
//
//  Created by IF on 15/1/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveFooterView.h"

@interface ActiveFooterView ()<UIAlertViewDelegate,ASIHTTPRequestDelegate>{

}

-(void)initWithActiveFooter:(ActiveFooterView *) footerView;

@end

@implementation ActiveFooterView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initWithActiveFooter:self];
    }
    return self;
}

-(void)initWithActiveFooter:(ActiveFooterView *) footerView{
    
    [footerView setBackgroundColor:[UIColor whiteColor]];
    UIButton *addContentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addContentBtn.frame=CGRectMake(20, 2, footerView.frame.size.width-2*20, 40);
    [addContentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addContentBtn.layer.borderWidth = 0.5f;
    addContentBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [addContentBtn setTitle:@"➕    Add a option..." forState:UIControlStateNormal];
    [addContentBtn addTarget:self action:@selector(addMutableOptionContentVote) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addContentBtn];
}


-(void) addMutableOptionContentVote {
    UIAlertView  * alertView = [[UIAlertView alloc] initWithTitle:@"Add a option" message:[self.voteOptionDic objectForKey:@"title"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirend", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITextField * textValue = [alertView textFieldAtIndex:0];
        NSString * evId =  [self.voteOptionDic objectForKey:@"id"];
        
        NSDictionary * optionDic = @{@"option":textValue.text};
        NSString * jsonStr = [[NSArray arrayWithObjects:optionDic, nil] JSONString];
    
        
        ASIHTTPRequest * request = [t_Network httpPostValue:@{@"evid":evId,@"option":jsonStr}.mutableCopy Url:anyTime_AddEventVoteOption Delegate:self Tag:anyTime_AddEventVoteOption_tag];
        [request startAsynchronous];
        
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseStr = [request responseString];
    NSDictionary *tmpDic = [responseStr objectFromJSONString];
    switch (request.tag) {
        case anyTime_AddEventVoteOption_tag:
        {
            NSString *statusCode = [tmpDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                NSArray * tmpArr = [tmpDic objectForKey:@"data"];
                if (self.delegate && [self.delegate respondsToSelector:@selector(activeFooterView:returnValue:selectSection:)]) {
                    [self.delegate activeFooterView:self returnValue:tmpArr selectSection:self.selectSection];
                }
            }
        }
    }
}

@end
