//
//  YYNotification.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


typedef NS_ENUM(NSUInteger, YYNotificationKind)
{
    YYNotificationKindVote = 1,
    YYNotificationKindComment
};


NS_ASSUME_NONNULL_BEGIN

@interface YYNotification : YYThing <MTLJSONSerializing>

@property (nonatomic, readonly) BOOL     unread;
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) NSString *subject;

@property (nonatomic, readonly, nullable) NSString *replyIdentifier;

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSString  *key;
@property (nonatomic, readonly) NSString  *hashKey;

@property (nonatomic, readonly) NSString *priority;
@property (nonatomic, readonly) BOOL     isNormalPriority;

@property (nonatomic, readonly) NSString *thingIdentifier;
@property (nonatomic, readonly) BOOL     thingIsComment;

@property (nonatomic, readonly) id __v;
@property (nonatomic, readonly) id updated;
@property (nonatomic, readonly) NSString *userIdentifier;

@end

NS_ASSUME_NONNULL_END