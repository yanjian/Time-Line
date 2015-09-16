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

-(instancetype)initChatModelDataWithActiveEventModel:(ActiveEventModel *)activeEvent{
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray arrayWithCapacity:0];
        self.avatars  = [NSMutableDictionary dictionary] ;
        self.users    = [NSMutableDictionary dictionary] ;
        self.memberTempArr = [NSMutableArray array];
        self.avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"smile_1"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault] ;//默认头像

        if (activeEvent) {
            self.activeEvent = activeEvent ;
            
            [self loadFakeMessages];
            
            NSArray * memberArr = self.activeEvent.invitees ;
            
            for (NSDictionary *memberDic in memberArr) {
                MemberDataModel *memberDataMode = [MemberDataModel modelWithDictionary:memberDic];
                [self.memberTempArr addObject:memberDataMode];
            }
            
            for ( MemberDataModel *memberDataMode in self.memberTempArr) {
                NSString * imgSmall = [memberDataMode.user objectForKey:@"thumbnail"];
                NSString * imgPath  = [[NSString stringWithFormat:@"%@%@",BaseGo2Url_IP,imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [self.avatars setObject:[NSURL URLWithString:imgPath] forKey:memberDataMode.uid] ;
                [self.users   setObject:[memberDataMode.user objectForKey:@"username"] forKey:memberDataMode.uid ] ;
            }
        }
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
       
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self ;
}


- (void)loadFakeMessages
{
    NSPredicate * nspre = [NSPredicate predicateWithFormat:@"eid==%@",self.activeEvent.Id];
    NSArray * chatContentArr = [ChatContentModel MR_findAllWithPredicate:nspre];
    for (ChatContentModel *chatContent in chatContentArr) {
        chatContent.unreadMessage = @( UNREADMESSAGE_YES ) ;//变为已读
        if (chatContent.imgSmall && ![chatContent.imgSmall isEqualToString:@""]) {//是否是图片
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[NSData dataWithBase64String:chatContent.imgSmall]]];
            if (![[UserInfo currUserInfo].Id isEqualToString:chatContent.uid]) {
                 photoItem.appliesMediaViewMaskAsOutgoing = NO ;
            }
            JSQMessage *photoMessage = [[JSQMessage alloc] initWithSenderId:chatContent.uid
                                                            senderDisplayName:chatContent.username
                                                                         date:[[PublicMethodsViewController getPublicMethods] stringToDate:chatContent.time]
                                                                        media:photoItem];
            [self.messages addObject:photoMessage];
        }else{
            JSQMessage *reallyMessage =[[JSQMessage alloc] initWithSenderId:chatContent.uid
                                                          senderDisplayName:chatContent.username
                                                                       date:[[PublicMethodsViewController getPublicMethods] stringToDate:chatContent.time]
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
