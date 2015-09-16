//
//  ChatViewController.m
//  Go2
//
//  Created by IF on 15/3/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatContentModel.h"
#import "MemberDataModel.h"
#import "UserInfo.h"
#import "camera.h"
#import "utilities.h"
#import "SJAvatarBrowser.h"
#import "UIImageView+WebCache.h"

@interface ChatViewController (){
     UIActionSheet *action;
     UIImage   * sendImage;
}

@end
@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.activeEvent.title;

    self.senderId = [UserInfo currUserInfo].Id;
    
    self.senderDisplayName = [UserInfo currUserInfo].username;
    
    self.showLoadEarlierMessagesHeader = NO ;
    
    self.chatModelData = [[ChatModelData alloc] initChatModelDataWithActiveEventModel:self.activeEvent];
    
    //收到信息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchChatGroupInfo:) name:CHATGROUP_ACTIVENOTIFICTION object:nil];
    
    self.showLoadEarlierMessagesHeader = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //告诉接受到的信息在存入到数据库时已读
    g_AppDelegate.isRead = @(UNREADMESSAGE_YES);
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"UPDATES" ;
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
    [self netWorkSendChatMsgChatStr:text withChatImage:nil] ;//聊天信息发送到对方
}

-(void)netWorkSendChatMsgChatStr:(NSString *)chatmsg withChatImage:(UIImage *)chatImage {
    ASIFormDataRequest *uploadImageRequest;
    if(chatImage){
           NSURL *url = [NSURL URLWithString:[Go2_UploadSocialFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
           [uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
           [uploadImageRequest setRequestMethod:@"POST"];
           [uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
           [uploadImageRequest setPostValue:@"chat" forKey:@"type"];
           [uploadImageRequest setPostValue:chatmsg==nil?@"":chatmsg forKey:@"msg"];
           [uploadImageRequest setPostValue:self.activeEvent.Id forKey:@"eid"];
           [uploadImageRequest setTimeOutSeconds:20];

        NSData *data = UIImagePNGRepresentation(chatImage);
        NSMutableData *imageData = [NSMutableData dataWithData:data];
        NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
        [uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
    }else{
         uploadImageRequest = [t_Network httpPostValue:@{@"method":@"sendChatMsg",@"msg":chatmsg==nil?@"":chatmsg,@"eid":self.activeEvent.Id}.mutableCopy
                                                                      Url:Go2_socials
                                                                 Delegate:nil
                                                                      Tag:Go2_SendMsg_tag];
    }
    __block ASIFormDataRequest *uploadRequest = uploadImageRequest;
    [uploadImageRequest setCompletionBlock: ^{
        NSString *responseStr = [uploadRequest responseString];
        NSLog(@"数据更新成功：%@", responseStr);
        id obj = [responseStr objectFromJSONString];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)obj;
            NSInteger  statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
            if ( statusCode == 1 ) {
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
    ChatContentModel * chatContent = [notification.userInfo objectForKey:CHATGROUP_USERINFO];
    
    if ([chatContent.eid isEqualToString:self.activeEvent.Id]) {//收到的通知与打开的活动的eid是相同的就显示在聊天上.....
        
        self.showTypingIndicator = !self.showTypingIndicator;
        [self scrollToBottomAnimated:YES];
        JSQMessage *message;
        if (chatContent.imgSmall && ![@"" isEqualToString:chatContent.imgSmall]) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[NSData dataWithBase64String:chatContent.imgSmall]]];
            photoItem.appliesMediaViewMaskAsOutgoing = NO ;
            
            message = [[JSQMessage alloc] initWithSenderId:chatContent.uid
                                         senderDisplayName:chatContent.username
                                                      date:[[PublicMethodsViewController getPublicMethods] stringToDate:chatContent.time]
                                                     media:photoItem];
        }else if(chatContent.text){
            message = [[JSQMessage alloc] initWithSenderId:chatContent.uid
                                         senderDisplayName:chatContent.username
                                                      date:[[PublicMethodsViewController getPublicMethods] stringToDate:chatContent.time] //[NSDate distantPast]
                                                      text:chatContent.text];
        }
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.chatModelData.messages addObject:message];
        [self finishReceivingMessageAnimated:YES];
    }
}


- (void)didPressAccessoryButton:(UIButton *)sender
{
    action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo", nil];
    [action showInView:self.view];

}


#pragma mark -该方法是UIActionsheet的回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%i", buttonIndex);
    if ( buttonIndex == 0 ) {
       ShouldStartCamera(self, YES);
    }else if ( buttonIndex == 1 ) {
       ShouldStartPhotoLibrary(self, YES);
    }
}



#pragma mark -选择完相片后回调的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image.size.width > 140) {
        image = ResizeImage(image, 140, 140);
    }
    sendImage = image ;
    [self.chatModelData addPhotoMediaMessage:image senderId:self.senderId displayName:self.senderDisplayName ] ;
    [self finishReceivingMessageAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self netWorkSendChatMsgChatStr:nil withChatImage:sendImage] ;//聊天信息发送到对方
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
    }else{
        return  self.chatModelData.incomingBubbleImageData ;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil ;
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
    
    
    NSLog(@"%@",[self.chatModelData.avatars objectForKey:msg.senderId]) ;
    
    [cell.avatarImageView sd_setImageWithURL:[self.chatModelData.avatars objectForKey:msg.senderId] placeholderImage:[UIImage imageNamed:@"smile_1"]] ;
    
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
    JSQMessage *msg = [self.chatModelData.messages objectAtIndex:indexPath.item];
    if (msg.isMediaMessage) {
        if ([msg.media isKindOfClass:[JSQPhotoMediaItem class]]){
            JSQPhotoMediaItem * tmpMediaIeem =  (JSQPhotoMediaItem *) msg.media ;
            UIImageView * tmpImgView = [[UIImageView alloc] initWithImage:tmpMediaIeem.image];
            [SJAvatarBrowser showImage:tmpImgView];
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
