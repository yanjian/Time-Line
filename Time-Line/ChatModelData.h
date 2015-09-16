//
//  ChatModelData.h
//  Go2
//
//  Created by IF on 15/3/11.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"
#import "ActiveEventModel.h"

@interface ChatModelData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) ActiveEventModel * activeEvent;

@property (strong, nonatomic) NSMutableArray * memberTempArr;

@property (strong, nonatomic)  JSQMessagesAvatarImage *avatarImageBlank;

-(instancetype)initChatModelDataWithActiveEventModel:(ActiveEventModel *) activeEvent;

- (void)addPhotoMediaMessage:(UIImage * )image senderId:(NSString *)senderId displayName:(NSString *)name;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

- (void)addVideoMediaMessage;

@end
