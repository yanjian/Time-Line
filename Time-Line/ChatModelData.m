//
//  ChatModelData.m
//  Go2
//
//  Created by IF on 15/3/11.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ChatModelData.h"
#import "ChatContentModel.h"
#import "MemberDataModel.h"

@implementation ChatModelData

-(instancetype)initChatModelDataWithActiveEventModel:(ActiveEventMode *)activeEvent{
    self = [super init];
    if (self) {
        self.activeEvent = activeEvent ;
        self.messages = [NSMutableArray arrayWithCapacity:0];
        self.avatars  = [NSMutableDictionary dictionary] ;
        self.memberTempArr = [NSMutableArray array];
        
        self.avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"smile_1"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault] ;//默认头像

        [self loadFakeMessages];
        
        NSArray * memberArr = self.activeEvent.member ;
       
        NSMutableDictionary *userDic = [NSMutableDictionary dictionary] ;

        for (NSDictionary *memberDic in memberArr) {
            MemberDataModel *memberDataMode = [[MemberDataModel alloc] init];
            [memberDataMode parseDictionary:memberDic];
            [self.memberTempArr addObject:memberDataMode];
        }
        
        for ( MemberDataModel *memberDataMode in self.memberTempArr) {
            [userDic    setObject:memberDataMode.username forKey:[memberDataMode.uid stringValue]] ;
        }
        
        self.users = userDic;

        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self ;
}


- (void)loadFakeMessages
{
    NSPredicate *nspre=[NSPredicate predicateWithFormat:@"eid==%@",self.activeEvent.Id];
    NSArray *chatContentArr=[ChatContentModel MR_findAllWithPredicate:nspre];
    for (ChatContentModel *chatContent in chatContentArr) {
        chatContent.unreadMessage = @(UNREADMESSAGE_YES) ;//变为已读
        if (chatContent.imgSmall && ![chatContent.imgSmall isEqualToString:@""]) {//是否是图片
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[NSData dataWithBase64String:chatContent.imgSmall]]];
            JSQMessage *photoMessage = [JSQMessage messageWithSenderId:chatContent.uid
                                                           displayName:chatContent.username
                                                                 media:photoItem];
            [self.messages addObject:photoMessage];
        }else{
            JSQMessage *reallyMessage =[[JSQMessage alloc] initWithSenderId:chatContent.uid
                                                          senderDisplayName:chatContent.username
                                                                       date:[NSDate distantPast]
                                                                       text:chatContent.text];
            [self.messages addObject:reallyMessage] ;
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}


- (void)addPhotoMediaMessage:(UIImage * )image senderId:(NSString *)senderId displayName:(NSString *)name
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:name
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:nil
                                                      displayName:nil
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
    NSURL *videoURL = [NSURL URLWithString:@"file://"];
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:nil
                                                   displayName:nil
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}


@end
