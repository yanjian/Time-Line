//
//  ActiveAlbumsTableViewController.m
//  Go2
//
//  Created by IF on 15/4/8.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveAlbumsTableViewController.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"
#import "ActiveImgModel.h"

@interface ActiveAlbumsTableViewController ()
@property (nonatomic, strong) NSMutableArray *activeArray;
@end

@implementation ActiveAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 200;
    _activeArray = @[].mutableCopy;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    ASIHTTPRequest *request = [t_Network httpGet:@{ @"eid":self.eid }.mutableCopy Url:anyTime_GetEventChatImg Delegate:nil Tag:anyTime_GetEventChatImg_tag];
    __block ASIHTTPRequest *aliasRequest = request;
    [request setCompletionBlock: ^{
        NSString *responseStr = [aliasRequest responseString];
        id objGroup = [responseStr objectFromJSONString];
        if ([objGroup isKindOfClass:[NSDictionary class]]) {
            NSString *statusCode = [objGroup objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                NSArray *tmpArr =  [objGroup objectForKey:@"data"];
                for (NSDictionary *dic in tmpArr) {
                    ActiveImgModel * activeImg = [[ActiveImgModel alloc] init];
                    [activeImg parseDictionary:dic] ;
                    [_activeArray addObject:activeImg] ;
                }
            }
        }
    }];
    [request setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error!"];
    }];
    [request startSynchronous];
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"ALBUMS" ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_activeArray.count%4 == 0) {
        return _activeArray.count/4 *80 ;
    }else{
        return (_activeArray.count/4+1) * 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    SDPhotoGroup *photoGroup = [[SDPhotoGroup alloc] init];
    
    NSMutableArray *temp = [NSMutableArray array];
    [_activeArray enumerateObjectsUsingBlock:^(ActiveImgModel * activeImg, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item   = [[SDPhotoItem alloc] init];
        item.thumbnail_pic  = activeImg.imgSmall;
        item.tremendous_pic = activeImg.imgBig;
        [temp addObject:item];
    }];
    photoGroup.photoItemArray = [temp copy];
    [cell.contentView addSubview:photoGroup];
    
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

@end
