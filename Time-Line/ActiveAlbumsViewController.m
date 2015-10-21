//
//  ActiveAlbumsViewController.m
//  Go2
//
//  Created by IF on 15/6/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveAlbumsViewController.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"
#import "ActiveImgModel.h"
#import "ImgShowViewController.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"

@interface ActiveAlbumsViewController ()<UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout>
{
    NSString *_identify;
}
@property (nonatomic, strong) NSMutableArray *activeArray;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ActiveAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    
    _activeArray = @[].mutableCopy;
    ASIHTTPRequest *request = [t_Network httpGet:@{@"method":@"getImages", @"eid":self.eid }.mutableCopy Url:Go2_socials Delegate:nil Tag:Go2_GetEventChatImg_tag];
    __block ASIHTTPRequest *aliasRequest = request;
    [request setCompletionBlock: ^{
        NSString *responseStr = [aliasRequest responseString];
        id objGroup = [responseStr objectFromJSONString];
        if ([objGroup isKindOfClass:[NSDictionary class]]) {
            int statusCode = [[objGroup objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
                NSArray *tmpArr =  [objGroup objectForKey:@"datas"];
                for (NSDictionary *dic in tmpArr) {
                    ActiveImgModel * activeImg = [ActiveImgModel modelWithDictionary:dic];
                    [_activeArray addObject:activeImg] ;
                }
            }
        }
    }];
    [request setFailedBlock: ^{
        [MBProgressHUD showError:@"Network error!"];
    }];
    [request startSynchronous];
    [self _init];
}

- (NSString *)segmentTitle{
    return @"ALBUMS" ;
}



- (void)_init{
    
    //为当前UICollectionView对象创建布局对象
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(75, 75);
    flowLayout.minimumLineSpacing = 5.f;
    flowLayout.minimumInteritemSpacing = 5.f;
    
    self.collectionView.collectionViewLayout = flowLayout ;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //注册单元格
    _identify = @"PhotoCell";
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_identify];
    
    [self.view addSubview:self.collectionView];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _activeArray.count;
}

// 单元格代理
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    ActiveImgModel * activeImg = _activeArray[indexPath.row];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    
    NSString *_urlStr = [ [NSString stringWithFormat:@"%@%@",BaseGo2Url_IP,activeImg.thumbnail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    
    [imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"go2_grey"]];
    imgView.contentMode = UIViewContentModeScaleToFill;
    
    imgView.frame = CGRectMake(0, 0, 80, 80);
    
    [cell.contentView addSubview:imgView];
    return cell;
}

-(UIScrollView *)streachScrollView
{
    return self.collectionView;
}

// 单元格选择代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 深拷贝数据
    NSMutableArray *imgList = [NSMutableArray arrayWithCapacity:_activeArray.count];
    for (int i = 0; i < _activeArray.count; i++) {
        ActiveImgModel * activeImg = _activeArray[i] ;
        NSString *_urlStr = [[NSString stringWithFormat:@"%@%@",BaseGo2Url_IP,activeImg.img ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [imgList addObject:[NSURL URLWithString:_urlStr]];
    }
    
    // 调用展示窗口
    ImgShowViewController *imgShow = [[ImgShowViewController alloc] initWithSourceData:imgList withIndex:indexPath.row];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgShow];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [nav.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -View生命周期
- (void)viewWillAppear:(BOOL)animated{
    // 导航栏不透明
    if (self.navigationController.navigationBar.translucent) {
        self.navigationController.navigationBar.translucent = NO;
    }
}



#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_activeArray.count%4 == 0) {
//        return _activeArray.count/4 *80 ;
//    }else{
//        return (_activeArray.count/4+1) * 80;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *ID = @"photo";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    }
//    SDPhotoGroup *photoGroup = [[SDPhotoGroup alloc] init];
//    NSMutableArray *temp = [NSMutableArray array];
//    [_activeArray enumerateObjectsUsingBlock:^(ActiveImgModel * activeImg, NSUInteger idx, BOOL *stop) {
//        SDPhotoItem *item   = [[SDPhotoItem alloc] init];
//        item.thumbnail_pic  = activeImg.imgSmall;
//        item.tremendous_pic = activeImg.imgBig;
//        [temp addObject:item];
//    }];
//    photoGroup.photoItemArray = [temp copy];
//    [cell.contentView addSubview:photoGroup];
//
//    return cell;
//}


@end
