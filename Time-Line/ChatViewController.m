//
//  ChatViewController.m
//  Time-Line
//
//  Created by IF on 15/3/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatContentModel.h"
#import "MemberDataModel.h"
#import "UserInfo.h"

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.activeEvent.title;

    self.senderId = [UserInfo currUserInfo].Id;
    self.senderDisplayName = [UserInfo currUserInfo].username;
    
    
    self.chatModelData = [[ChatModelData alloc] initChatModelDataWithActiveEventModel:self.activeEvent];
    
    //收到信息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchChatGroupInfo:) name:CHATGROUP_ACTIVENOTIFICTION object:nil];
    
    self.showLoadEarlierMessagesHeader = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //告诉接受到的信息在存入到数据库时已读
    g_AppDelegate.isRead = @(UNREADMESSAGE_YES);

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    g_AppDelegate.isRead = @(UNREADMESSAGE_NO);
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.chatModelData.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
   
    //
    NSURL *url = [NSURL URLWithString:[anyTime_SendMsg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIFormDataRequest *uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
    [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
    [uploadImageRequest setRequestMethod:@"POST"];
    [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [uploadImageRequest setPostValue:text forKey:@"msg"];
    [uploadImageRequest setPostValue:self.activeEvent.Id forKey:@"eid"];
    [uploadImageRequest setTimeOutSeconds:20];
    [uploadImageRequest addData:[NSData new] withFileName:@""  andContentType:@"image/jpeg" forKey:@"f1"];
    [uploadImageRequest setTag:anyTime_SendMsg_tag];
    __block ASIFormDataRequest *uploadRequest = uploadImageRequest;
    [uploadImageRequest setCompletionBlock: ^{
        NSString *responseStr = [uploadRequest responseString];
        NSLog(@"数据更新成功：%@", responseStr);
        id obj = [responseStr objectFromJSONString];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)obj;
            NSInteger  statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
            if (statusCode == 1) {
                id dataDic = [tmpDic objectForKey:@"data"];
                if ([dataDic isKindOfClass:[NSDictionary class]]) {
                     [g_AppDelegate saveChatInfoForActive:dataDic];
                }
            }
        }
    }];
    [uploadImageRequest setFailedBlock: ^{
        NSLog(@"请求失败：%@", [uploadRequest responseString]);
    }];
    [uploadImageRequest startAsynchronous];
}

-(void)fetchChatGroupInfo:(NSNotification *) notification {
    
     self.showTypingIndicator = !self.showTypingIndicator;
    
    [self scrollToBottomAnimated:YES];
    
    ChatContentModel * chatContent = [notification.userInfo objectForKey:CHATGROUP_USERINFO];
    JSQMessage *message;
    if (chatContent.imgSmall) {
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[NSData dataWithBase64String:chatContent.imgSmall]]];
         message = [JSQMessage messageWithSenderId:chatContent.uid
                                                       displayName:chatContent.username
                                                             media:photoItem];
        
       
    }else if(chatContent.text){
        message = [[JSQMessage alloc] initWithSenderId:chatContent.uid
                                     senderDisplayName:chatContent.username
                                                  date:[NSDate distantPast]
                                                  text:chatContent.text];
    }
   
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self.chatModelData.messages addObject:message];
    [self finishReceivingMessageAnimated:YES];

}



- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatModelData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatModelData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.chatModelData.outgoingBubbleImageData;
    }
    
    return self.chatModelData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatModelData.messages objectAtIndex:indexPath.item];
    if (self.chatModelData.avatars[message.senderId]==nil) {
        for (MemberDataModel *memberData in self.chatModelData.memberTempArr) {
            if ([message.senderId isEqualToString: memberData.uid.stringValue]) {
                if (memberData.imgSmall) {
                    NSString * imgSmall = [memberData.imgSmall stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    NSString * imgPath = [[NSString stringWithFormat:@"%@/%@",BASEURL_IP,imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgPath]];
                    
                    self.chatModelData.avatars[message.senderId] =  [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imgData]   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];;
                }
            }
        }
        //[self.collectionView reloadData];
        return self.chatModelData.avatarImageBlank;
    }else return [self.chatModelData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatModelData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatModelData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatModelData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatModelData.messages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.chatModelData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.chatModelData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatModelData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}


#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
