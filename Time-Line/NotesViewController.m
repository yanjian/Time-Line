//
//  NotesViewController.m
//  Time-Line
//
//  Created by connor on 14-4-23.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "NotesViewController.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _noteText=[[UITextView alloc] initWithFrame:CGRectMake(10, 75, 290, 100)];
    _noteText.delegate=self;
    _noteText.font=[UIFont systemFontOfSize:17.0f];
    [[PublicMethodsViewController getPublicMethods] setCorner:_noteText radius:6.0f borderWidth:0.4f];
    [self.view addSubview:_noteText];
    [_noteText becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_noteText resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated{
   [_delegate getnotes:_noteText.text];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
