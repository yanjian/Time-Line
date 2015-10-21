//
//  Go2ChildTableViewController.m
//  Go2
//
//  Created by IF on 15/9/18.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "Go2ChildTableViewController.h"
#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"
#import "UserInfo.h"

@interface Go2ChildTableViewController(){
    
    }
@property (nonatomic, weak) NSArray *emotionManagers;

@property (nonatomic, weak) XHMessageTableViewCell *currentSelectedCell;

@end

@implementation Go2ChildTableViewController


- (XHMessage *)getTextMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType chatContent:(ChatContentModel *) chatModel userHeader:(NSString *) headerStr{
    
    
        XHMessage *textMessage = [[XHMessage alloc] initWithText:[NSString stringFromBase64String:chatModel.text]
                                                          sender:chatModel.username
                                                       timestamp:[[PublicMethodsViewController getPublicMethods] stringToDate:chatModel.time]];
        textMessage.avatar = [UIImage imageNamed:@"smile_1"];
        textMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, headerStr];
        textMessage.bubbleMessageType = bubbleMessageType;
    
        return textMessage;
}

- (XHMessage *)getPhotoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType  chatContent:(ChatContentModel *) chatModel userHeader:(NSString *) headerStr{
    
        XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:nil
                                                      thumbnailUrl:[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [NSString stringFromBase64String:chatModel.imgBig]]
                                                    originPhotoUrl:[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [NSString stringFromBase64String:chatModel.imgBig]]
                                                            sender:chatModel.username
                                                         timestamp:[[PublicMethodsViewController getPublicMethods] stringToDate:chatModel.time]];
        photoMessage.avatar = [UIImage imageNamed:@"smile_1"];
        photoMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, headerStr];
        photoMessage.bubbleMessageType = bubbleMessageType;
    
        return photoMessage;
}

- (XHMessage *)getVideoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1555.MOV" ofType:@""];
        XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath]
                                                                    videoPath:videoPath
                                                                     videoUrl:nil
                                                                       sender:@"Jayson"
                                                                    timestamp:[NSDate date]];
        videoMessage.avatar = [UIImage imageNamed:@"smile_1"];
        videoMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
        videoMessage.bubbleMessageType = bubbleMessageType;
    
        return videoMessage;
    }

- (XHMessage *)getVoiceMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType chatContent:(ChatContentModel *) chatModel userHeader:(NSString *) headerStr isRead:(BOOL)isRead {
    NSLog(@"%@",[NSString stringFromBase64String:chatModel.voiceAac]);
        XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [NSString stringFromBase64String:chatModel.voiceAac]]
                                                              voiceUrl:[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [NSString stringFromBase64String:chatModel.voiceAac]]
                                                         voiceDuration:chatModel.text sender:chatModel.username timestamp:[NSDate date]
                                                                isRead:isRead];
        voiceMessage.avatar = [UIImage imageNamed:@"smile_1"];
        voiceMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, headerStr];
        voiceMessage.bubbleMessageType = bubbleMessageType;
    
        return voiceMessage;
}

//- (XHMessage *)getEmotionMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
//        XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"Demo0.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
//        emotionMessage.avatar = [UIImage imageNamed:@"smile_1"];
//        emotionMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
//        emotionMessage.bubbleMessageType = bubbleMessageType;
//    
//        return emotionMessage;
//    }

//- (XHMessage *)getGeolocationsMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
//    
//        XHMessage *localPositionMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:113.399444] sender:@"Jack" timestamp:[NSDate date]];
//        localPositionMessage.avatar = [UIImage imageNamed:@"smile_1"];
//        localPositionMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
//        localPositionMessage.bubbleMessageType = bubbleMessageType;
//    
//        return localPositionMessage;
//    }


- (void)loadDemoDataSource {
        WEAKSELF
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             //NSMutableArray *messages = [weakSelf getTestMessages];
               NSMutableArray * messages = [weakSelf loadFakeMessages];
                dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.messages = messages;
                        [weakSelf.messageTableView reloadData];
                        [weakSelf scrollToBottomAnimated:NO];
                 });
            });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    g_AppDelegate.isRead = @(UNREADMESSAGE_YES);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[XHAudioPlayerHelper shareInstance] stopAudio];
}

- (NSMutableArray *)loadFakeMessages
{
        NSPredicate * nspre = [NSPredicate predicateWithFormat:@"eid == %@",self.activeEvent.Id];
        NSArray * chatContentArr = [ChatContentModel MR_findAllWithPredicate:nspre];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
    
        for (ChatContentModel * chatContent in chatContentArr) {
             chatContent.unreadMessage = @( UNREADMESSAGE_YES ) ;//变为已读
             XHBubbleMessageType messageType = [[UserInfo currUserInfo].Id isEqualToString:chatContent.uid]?XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving ;
            NSPredicate * tmpPre = [NSPredicate predicateWithFormat:@"uid == %@ ",chatContent.uid];
            
            NSDictionary * userDic = [[self.activeEvent.invitees filteredArrayUsingPredicate:tmpPre] firstObject];
            NSString * thumbnailH = [[userDic objectForKey:@"user"] objectForKey:@"thumbnail"];
             if( [chatContent.msg_type intValue] == 0 ){   //0 表示只是文本信息
                [messages addObject:[self getTextMessageWithBubbleMessageType:messageType  chatContent:chatContent userHeader:thumbnailH  ]];
             }else if ([chatContent.msg_type intValue] == 1){//1.表示 只是图片信息
                [messages addObject:[self getPhotoMessageWithBubbleMessageType: messageType chatContent:chatContent userHeader: thumbnailH ]];
             }else if([chatContent.msg_type intValue] == 2 ){//2.表示语音
                  [messages addObject:[self getVoiceMessageWithBubbleMessageType:messageType chatContent:chatContent userHeader:thumbnailH isRead:NO]];
             }
            
        }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return messages ;
}

- (NSString *)segmentTitle{
        return @"CHAT" ;
}

-(UIScrollView *)streachScrollView
{
    return self.messageTableView;
}

- (void)viewDidLoad{
        [super viewDidLoad];
        if (CURRENT_SYS_VERSION >= 7.0) {
                self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
            }
        // 设置自身用户名
        self.messageSender = [UserInfo currUserInfo].username;
    
        // 添加第三方接入数据
        NSMutableArray *shareMenuItems = [NSMutableArray array];
        NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video"];
        NSArray *plugTitle = @[@"照片", @"拍摄"];
        for (NSString *plugIcon in plugIcons) {
            XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
            [shareMenuItems addObject:shareMenuItem];
        }
    //
    //    NSMutableArray *emotionManagers = [NSMutableArray array];
    //    for (NSInteger i = 0; i < 10; i ) {
    //        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
    //        emotionManager.emotionName = [NSString stringWithFormat:@"表情%ld", (long)i];
    //        NSMutableArray *emotions = [NSMutableArray array];
    //        for (NSInteger j = 0; j < 32; j ) {
    //            XHEmotion *emotion = [[XHEmotion alloc] init];
    //            NSString *imageName = [NSString stringWithFormat:@"section%ld_emotion%ld", (long)i , (long)j % 16];
    //            emotion.emotionPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Demo%ld.gif", (long)j % 2] ofType:@""];
    //            emotion.emotionConverPhoto = [UIImage imageNamed:imageName];
    //            [emotions addObject:emotion];
    //        }
    //        emotionManager.emotions = emotions;
    //
    //        [emotionManagers addObject:emotionManager];
    //    }
    //
    //    self.emotionManagers = emotionManagers;
    //    [self.emotionManagerView reloadData];
    
        self.shareMenuItems = shareMenuItems;
        [self.shareMenuView reloadData];
        [self loadDemoDataSource];
    
    //收到信息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchChatGroupInfo:) name:CHATGROUP_ACTIVENOTIFICTION object:nil];
}

- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)dealloc {
        self.emotionManagers = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CHATGROUP_ACTIVENOTIFICTION object:nil];
}

#pragma mark - XHMessageTableViewCell delegate
- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            DLog(@"message : %@", message.photo);
            DLog(@"message : %@", message.videoConverPhoto);
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            DLog(@"message : %@", message.voicePath);
            
            message.isRead = YES;
            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            
            [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
    
}


- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
        DLog(@"text : %@", message.text);
        XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
        displayTextViewController.message = message;
        [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatarOnMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
        DLog(@"indexPath : %@", indexPath);
    
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
    }


#pragma mark - XHAudioPlayerHelper Delegate
- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource
- (NSInteger)numberOfEmotionManagers {
        return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
        return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
        return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
        return YES;
    }

- (void)loadMoreMessagesScrollTotop {
        if (!self.loadingMoreMessage) {
                self.loadingMoreMessage = YES;
        
                WEAKSELF
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            NSMutableArray *messages = [weakSelf getTestMessages];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [weakSelf insertOldMessages:messages];
        //                weakSelf.loadingMoreMessage = NO;
        //            });
        //        });
            }
}

/**
   *  发送文本消息的回调方法
   *
   *  @param text   目标文本字符串
   *  @param sender 发送者的名字
   *  @param date   发送时间
   */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
        XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
        textMessage.avatar = [UIImage imageNamed:@"smile_1"];
        textMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
        [self addMessage:textMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText xHMessage:textMessage idOfActive:self.activeEvent.Id];
    }

/**
   *  发送图片消息的回调方法
   *  @param photo  目标图片对象，后续有可能会换
   *  @param sender 发送者的名字
   *  @param date   发送时间
   */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
        XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
        photoMessage.avatar = [UIImage imageNamed:@"smile_1"];
        photoMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
        [self addMessage:photoMessage];
    
     [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto xHMessage:photoMessage idOfActive:self.activeEvent.Id];
}


/**
   *  发送视频消息的回调方法
   *
   *  @param videoPath 目标视频本地路径
   *  @param sender    发送者的名字
   *  @param date      发送时间
   */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
        XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:videoConverPhoto videoPath:videoPath videoUrl:nil sender:sender timestamp:date];
        videoMessage.avatar = [UIImage imageNamed:@"smile_1"];
        videoMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
        [self addMessage:videoMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVideo];
}

/**
   *  发送语音消息的回调方法
   *
   *  @param voicePath        目标语音本地路径
   *  @param voiceDuration    目标语音时长
   *  @param sender           发送者的名字
   *  @param date             发送时间
   */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
        XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
        voiceMessage.avatar = [UIImage imageNamed:@"smile_1"];
        voiceMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
        [self addMessage:voiceMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice xHMessage:voiceMessage idOfActive:self.activeEvent.Id];

}

/**
   *  发送第三方表情消息的回调方法
   *
   *  @param facePath 目标第三方表情的本地路径
   *  @param sender   发送者的名字
   *  @param date     发送时间
   */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
        if (emotionPath) {
                XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
                emotionMessage.avatar = [UIImage imageNamed:@"smile_1"];
                emotionMessage.avatarUrl = [NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [UserInfo currUserInfo].thumbnail];
                [self addMessage:emotionMessage];
                [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
        
            } else {
                    [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"如果想测试，请运行MessageDisplayKitWeChatExample工程" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            }
    }

/**
   *  有些网友说需要发送地理位置，这个我暂时放一放
   */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
        XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
        geoLocationsMessage.avatar = [UIImage imageNamed:@"smile_1"];
        geoLocationsMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
        [self addMessage:geoLocationsMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
    }

/**
   *  是否显示时间轴Label的回调方法
   *
   *  @param indexPath 目标消息的位置IndexPath
   *
   *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
   */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.row % 2)
                return YES;
        else
                return NO;
    }

/**
   *  配置Cell的样式或者字体
   *
   *  @param cell      目标Cell
   *  @param indexPath 目标Cell所在位置IndexPath
   */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.row % 4) {
                cell.messageBubbleView.displayTextView.textColor = [UIColor colorWithRed:0.106 green:0.586 blue:1.000 alpha:1.000];
            } else {
                    cell.messageBubbleView.displayTextView.textColor = [UIColor blackColor];
                }
    }

/**
   *  协议回掉是否支持用户手动滚动
   *
   *  @return 返回YES or NO
   */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
        return YES;
}

-(void)fetchChatGroupInfo:(NSNotification *) notification{
     NSLog( @"%@",notification.userInfo );
    WEAKSELF
    ChatContentModel * chatContent = (ChatContentModel *) [notification.userInfo objectForKey:CHATGROUP_USERINFO];
    
    //chatContent.unreadMessage = @( UNREADMESSAGE_YES ) ;//变为已读
    XHBubbleMessageType messageType = [[UserInfo currUserInfo].Id isEqualToString:chatContent.uid]?XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving ;
    NSPredicate * tmpPre = [NSPredicate predicateWithFormat:@"uid == %@ ",chatContent.uid];
    
    NSDictionary * userDic = [[self.activeEvent.invitees filteredArrayUsingPredicate:tmpPre] firstObject];
    NSString * thumbnailH = [[userDic objectForKey:@"user"] objectForKey:@"thumbnail"];
    if( [chatContent.msg_type intValue] == 0 ){   //0 表示只是文本信息
        [weakSelf.messages addObject:[self getTextMessageWithBubbleMessageType:messageType  chatContent:chatContent userHeader:thumbnailH  ]];
    }else if ([chatContent.msg_type intValue] == 1){//1.表示 只是图片信息
        [weakSelf.messages addObject:[self getPhotoMessageWithBubbleMessageType: messageType chatContent:chatContent userHeader: thumbnailH ]];
    }else if([chatContent.msg_type intValue] == 2 ){//2.表示语音
        [weakSelf.messages addObject:[self getVoiceMessageWithBubbleMessageType:messageType chatContent:chatContent userHeader:thumbnailH isRead:NO]];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [weakSelf.messageTableView reloadData];
    [weakSelf scrollToBottomAnimated:YES];
}


@end