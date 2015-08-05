//
//  MRImgShowView.m
//  Project-Movie
//
//  Created by Minr on 14-11-15.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import "MRImgShowView.h"
#import "UIImageView+WebCache.h"
#pragma mark -定义宏常量
#define kImgViewCount 3

#define kImgZoomScaleMin 1
#define kImgZoomScaleMax 3

#pragma mark -定义展示板
#define kImgVLeft (UIImageView *)[_imgViewDic valueForKey:@"imgLeft"];
#define kImgVCenter (UIImageView *)[_imgViewDic valueForKey:@"imgCenter"];
#define kImgVRight (UIImageView *)[_imgViewDic valueForKey:@"imgRight"];

@implementation MRImgShowView
{
    UIScrollView *_scrCenter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSourceData:(NSMutableArray *)imgSource withIndex:(NSInteger)index withDelegate:(id<MRImgShowViewDelegate>) delegate{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.mrImgDelegate = delegate ;
        // 初始化控件属性
        [self initScrollView];
        
        // 设置数据源
        [self setImgSource:imgSource];
        
        // 设置图片下标
        [self setCurIndex:index];
        
        
    }
    return self;
}


#pragma mark -初始化控件
- (void)initScrollView{
 
    // 设置代理
    self.delegate = self;
    
    // 不显示滚动条
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    // 设置分页显示
    self.pagingEnabled = YES;
    
    //设置背景颜色
    self.backgroundColor = [UIColor clearColor];
    
    // 构建展示组
    [self initImgViewDic];
}

// 通过创建展示板
- (UIImageView *)creatImageView{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    return imgView;
}

// 通过位置创建展示板
- (UIScrollView *)scrollViewWithPosition:(MRImgLocation)imgLocation withImgView:(UIImageView *)imgView{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width * imgLocation, 0, width, height)];
    
    scrollView.backgroundColor = [UIColor clearColor];
    
    [scrollView addSubview:imgView];

    // 设置图片显示样式
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    return scrollView;
}

- (void)_initScrollCenter{
    // 设置缩放极限
    _scrCenter.maximumZoomScale = kImgZoomScaleMax;
    _scrCenter.minimumZoomScale = kImgZoomScaleMin;
    
    _scrCenter.delegate = self;
}

// 初始化展示板组
- (void)initImgViewDic{
    
    UIImageView *imgLeft = [self creatImageView];
    UIImageView *imgCenter =[self creatImageView];
    UIImageView *imgRight = [self creatImageView];
    
    _imgViewDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                   imgLeft, @"imgLeft",
                   imgCenter, @"imgCenter",
                   imgRight, @"imgRight", nil];
    
    UIScrollView *scrLeft =
    [self scrollViewWithPosition:MRImgLocationLeft withImgView:imgLeft];
    _scrCenter =
    [self scrollViewWithPosition:MRImgLocationCenter withImgView:imgCenter];
    UIScrollView *scrRight =
    [self scrollViewWithPosition:MRImgLocationRight withImgView:imgRight];
    
    // 初始化scrCenter
    [self _initScrollCenter];
    
    // 添加双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapClick:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self addGestureRecognizer:doubleTap];
    
    
    // 放入展示板
    [self addSubview:scrLeft];
    [self addSubview:_scrCenter];
    [self addSubview:scrRight];
    
    
}

#pragma mark -setAttribute
// 设置数据源
- (void)setImgSource:(NSMutableArray *)imgSource{
    
    if (_imgSource != imgSource) {
        _imgSource = imgSource ;
     
        //  设置展示板尺寸
        [self setConSize];
    }
}

// 展示板尺寸设置
- (void)setConSize{
    
    CGSize size = self.frame.size;
    
    //设置内容视图的大小--单页填充、横向划动
    self.contentSize = CGSizeMake(size.width * kImgViewCount, size.height);
    
    // 设置显示页
    [self setContentOffset:CGPointMake(size.width, 0)];
}

- (void)setCurIndex:(NSInteger)curIndex{
    
    if (_imgSource.count > curIndex && curIndex >= 0) {
        _curIndex = curIndex;
    } else if (curIndex == -1){
        _curIndex = _imgSource.count - 1;
    } else if (curIndex == _imgSource.count){
        _curIndex = 0;
    }
    
    // 判断数据类型 根据数据类型抉择使用情况
    // 如果需要使用URL，请导入延展
    Class urlCls = NSClassFromString(@"NSURL");
    
    if (_imgSource.count) {
        if ([_imgSource[0] isKindOfClass:urlCls]) {
            [self setAllImgVContentFromImage:[self imgListURLFromIndex:_curIndex]];
        }else{
            [self setAllImgVContentFromImage:[self imgListFromIndex:_curIndex]];
        }
    }
    
    if (self.mrImgDelegate && [self.mrImgDelegate respondsToSelector:@selector(mRImgShowView:currIndex:)]) {
        [self.mrImgDelegate mRImgShowView:self currIndex:curIndex];
    }
}

#pragma mark -功能函数
// 根据当前索引通过URL赋值图片
- (NSArray *)imgListURLFromIndex:(NSInteger)curIndex{
    
    long sCount = _imgSource.count;
    NSArray *imgList;
    NSURL *urlL;
    NSURL *urlC;
    NSURL *urlR;
    
    if (sCount) {
        
        // 首位
        if (curIndex == 0) {
            urlL = [_imgSource lastObject];
            urlC = _imgSource[curIndex];
            long nextIndex = curIndex == sCount - 1 ? curIndex : curIndex + 1;
            urlR = _imgSource[nextIndex];
        // 末位
        } else if (curIndex == sCount - 1){
            long lastIndex = curIndex == 0 ? curIndex : curIndex - 1;
            urlL = _imgSource[lastIndex] ;
            urlC = [_imgSource lastObject];
            urlR = _imgSource[0];
        // 中间
        } else {
            urlL = _imgSource[curIndex - 1] ;
            urlC = _imgSource[curIndex];
            urlR = _imgSource[curIndex + 1];
        }
        
        imgList = [[NSArray alloc] initWithObjects:urlL, urlC, urlR, nil];
    }
    
    return imgList;
}

// 根据当前索引赋值图片
- (NSArray *)imgListFromIndex:(NSInteger)curIndex{
    
    long sCount = _imgSource.count;
    NSArray *imgList;
    
    UIImage *imgL;
    UIImage *imgC;
    UIImage *imgR;
    
    if (sCount) {
        
        // 首位
        if (curIndex == 0) {
            imgL = [_imgSource lastObject];
            imgC = _imgSource[curIndex];
            long nextIndex = curIndex == sCount - 1 ? curIndex : curIndex + 1;
            imgR = _imgSource[nextIndex];
            // 末位
        } else if (curIndex == sCount - 1){
            long lastIndex = curIndex == 0 ? curIndex : curIndex - 1;
            imgL = _imgSource[lastIndex] ;
            imgC = [_imgSource lastObject];
            imgR = _imgSource[0];
            // 中间
        } else {
            imgL = _imgSource[curIndex - 1];
            imgC = _imgSource[curIndex];
            imgR = _imgSource[curIndex + 1];
        }
        
        imgList = [[NSArray alloc] initWithObjects:imgL, imgC, imgR, nil];
    }
    
    return imgList;
}

// 载入一组图片
- (void)setAllImgVContentFromImage:(NSArray *)imgList{
    
    // 将所有imgList中的数据载入展示板
    UIImageView *vLift = kImgVLeft;
    UIImageView *vCenter = kImgVCenter;
    UIImageView *vRight = kImgVRight;
    
    Class urlCls = NSClassFromString(@"NSURL");
    
    if (imgList.count) {
        if ([imgList[0] isKindOfClass:urlCls]) {
            [vLift   sd_setImageWithURL:imgList[MRImgLocationLeft]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                 [MBProgressHUD hideAllHUDsForView:self animated:YES];
            }];
            [vCenter sd_setImageWithURL:imgList[MRImgLocationCenter] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [MBProgressHUD hideAllHUDsForView:self animated:YES];
            }];
            [vRight  sd_setImageWithURL:imgList[MRImgLocationRight] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [MBProgressHUD hideAllHUDsForView:self animated:YES];
            }];
        }else{
            [vLift   setImage:imgList[MRImgLocationLeft]];
            [vCenter setImage:imgList[MRImgLocationCenter]];
            [vRight  setImage:imgList[MRImgLocationRight]];
        }
    }
}

// 谦让双击放大手势
- (void)requireDoubleGestureRecognizer:(UITapGestureRecognizer *)tep{
    [tep requireGestureRecognizerToFail:[[self gestureRecognizers] lastObject]];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self == scrollView) {
        CGFloat width = self.frame.size.width;
        int currentOffset = scrollView.contentOffset.x/width - 1;
        
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [self setCurIndex:_curIndex + currentOffset];
        
        [scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
        
        [_scrCenter setZoomScale:kImgZoomScaleMin];
    } else if (_scrCenter == scrollView)
    {
        CGFloat height = self.frame.size.height;
        CGFloat offsetY = _scrCenter.contentOffset.y;
        
        // 弹出判断
        if (height*1.8 < offsetY || offsetY < height*0.5) {
            [_scrCenter setZoomScale:kImgZoomScaleMin animated:YES];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIImageView *vCenter = kImgVCenter;
    return vCenter;
}

#pragma mark -Tap手势处理
- (void)doubleTapClick:(UITapGestureRecognizer *)tap{
    //判断当前放大的比例
    if (_scrCenter.zoomScale > kImgZoomScaleMin) {
        //缩小
        [_scrCenter setZoomScale:kImgZoomScaleMin animated:YES];
    }else{
        //放大
        [_scrCenter setZoomScale:kImgZoomScaleMax animated:YES];
    }
}
@end
