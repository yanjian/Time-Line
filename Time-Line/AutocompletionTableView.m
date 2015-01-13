

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#import "AutocompletionTableView.h"

@interface AutocompletionTableView () <UITextFieldDelegate,ASIHTTPRequestDelegate>
@property (nonatomic, strong) NSArray *suggestionOptions; // of selected NSStrings 
@property (nonatomic, strong) UITextField *textField; // will set automatically as user enters text
@property (nonatomic, strong) UIFont *cellLabelFont; // will copy style from assigned textfield
@end

@implementation AutocompletionTableView

@synthesize suggestionsDictionary = _suggestionsDictionary;
@synthesize suggestionOptions = _suggestionOptions;
@synthesize textField = _textField;
@synthesize cellLabelFont = _cellLabelFont;
@synthesize options = _options;
@synthesize locationDic=_locationDic;

#pragma mark - Initialization
- (UITableView *)initWithTextField:(UITextField *)textField inViewController:(UIViewController *) parentViewController withOptions:(NSDictionary *)options
{
    //set the options first
    self.options = options;
    
    // frame must align to the textfield 
    CGRect frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height, kScreen_Width,kScreen_Height);
    
    // save the font info to reuse in cells
    self.cellLabelFont = textField.font;
    
    self = [super initWithFrame:frame
             style:UITableViewStylePlain];
    
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = YES;
    
    // turn off standard correction
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // to get rid of "extra empty cell" on the bottom
    // when there's only one cell in the table
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textField.frame.size.width, 1)]; 
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
    self.hidden = YES;  
    [parentViewController.view addSubview:self];

    return self;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if ([self.options valueForKey:ACOUseSourceFont]) 
    {
        cell.textLabel.font = [self.options valueForKey:ACOUseSourceFont];
    } else 
    {
        cell.textLabel.font = self.cellLabelFont;
    }
    //移除contentview中的所有对象
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    if ([[self.suggestionOptions objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        NSString *tmpData= [self.suggestionOptions objectAtIndex:indexPath.row];
        if (0==indexPath.row) {
            UIImageView *addressIcon= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adress_Icon"]];
            addressIcon.frame=CGRectMake(5, 10, 18 , 22);
            UILabel *datalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 300, 22)];
            datalabel.text=tmpData;
            UILabel *dalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 22, 300, 22)];
            dalabel.text=@"自定义为止";

            [cell.contentView addSubview:datalabel];
            [cell.contentView addSubview:dalabel];
            [cell.contentView addSubview:addressIcon];
            
        }
    }else if ([[self.suggestionOptions objectAtIndex:indexPath.row] isKindOfClass:[NSArray class]]){
        NSArray *tmpArr=[self.suggestionOptions objectAtIndex:indexPath.row];
        if (tmpArr.count>1) {
            NSString *strData=@"";
            for (NSUInteger i=0; i<tmpArr.count; i++) {
                if (i==0) {
                    UILabel *datalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 300, 22)];
                    datalabel.text=tmpArr[i];
                    [cell.contentView addSubview:datalabel];
                }else{
                    strData=[NSString stringWithFormat:@"%@, %@",strData,tmpArr[i]];
                }
            }
            UILabel *dalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 22, 300, 22)];
            dalabel.text=strData;
            [cell.contentView addSubview:dalabel];
            
        }else{
            UILabel *datalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 300, 22)];
            datalabel.text=tmpArr[0];
            
            UILabel *dalabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 22, 300, 22)];
            dalabel.text=tmpArr[0];
            
            [cell.contentView addSubview:datalabel];
            [cell.contentView addSubview:dalabel];
        }
    }else{
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake(107, cell.contentView.bounds.origin.y+10, 106, 17)] ;
         imageView.image=[self.suggestionOptions lastObject];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tempStr=@"";
    if (indexPath.row==0) {
        tempStr=[self.suggestionOptions objectAtIndex:indexPath.row];
    }else{
        NSArray *tmpArr=[self.suggestionOptions objectAtIndex:indexPath.row];
        tempStr=tmpArr[0];
    }
    [self.textField setText:tempStr];
    [_autocompletionDelegate getTextField:tempStr locationDictionary:self.locationDic];
    [self hideOptionsView];
}

#pragma mark - UITextField delegate
- (void)textFieldValueChanged:(UITextField *)textField
{
    self.textField = textField;
    NSString *curString = textField.text;
    self.suggestionOptions=nil;
    if (![curString length])
    {
        [self hideOptionsView];
        return;
    } else{
        NSMutableDictionary *paramDic=@{@"input":[textField text],
                                        @"types":@"geocode",
                                        @"language":CurrentLanguage,
                                        @"sensor":@"false",
                                        @"types":@"geocode",
                                        @"key":GOOGLE_API_KEY }.mutableCopy;
        ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:GOOGLE_ADDRESS_REQUEST_SEARCH Delegate:self Tag:GOOGLE_ADDRESS_REQUEST_SEARCH_TAG];
        [request startAsynchronous];
        
    }
    
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",request.responseString);
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    NSMutableDictionary *tmpDir=[NSMutableDictionary dictionary];
    [tmpArray addObject:self.textField.text];
    NSMutableDictionary *responesDic=[request.responseString objectFromJSONString];
    NSString *responesStatus=[responesDic objectForKey:@"status"];//发送请求返回的状态
    if ([GOOGLE_STATUS_OK isEqualToString:responesStatus] ) {
        NSMutableArray *predicionsArr=[responesDic objectForKey:@"predictions"];
        
        for (NSMutableDictionary *ndic in predicionsArr) {
            NSLog(@"%@",[ndic valueForKey:@"description"]);
            NSMutableArray *ma=[NSMutableArray array];
            NSArray *tmpArr= [ndic valueForKey:@"terms"];
            for (NSUInteger i=0; i<tmpArr.count; i++) {
                if (0==i) {
                     [tmpDir setObject:[ndic valueForKey:@"reference"] forKey:[tmpArr[i] valueForKey:@"value"]];
                }
                [ma addObject:[tmpArr[i] valueForKey:@"value"]];
            }
            
            [tmpArray addObject:ma];
            
           
        }
    }else if([GOOGLE_STATUS_ZERO_RESULTS isEqualToString:responesStatus]){
        
    }
    [tmpArray insertObject:[UIImage imageNamed:@"powered-by-google-on-white"] atIndex:[tmpArray count]];
    self.suggestionOptions = tmpArray;
    self.locationDic=tmpDir;
    [self showOptionsView];
    [self reloadData];
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.textField resignFirstResponder];
//}


#pragma mark - Options view control
- (void)showOptionsView
{
    self.hidden = NO;
}

- (void) hideOptionsView
{
    self.hidden = YES;
}

@end
