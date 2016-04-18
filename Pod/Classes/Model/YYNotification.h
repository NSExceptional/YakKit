//
//  YYNotification.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


typedef NS_ENUM(NSUInteger, YYNotificationReason)
{
    YYNotificationReasonUnspecified,
    YYNotificationReasonVote = 1,
    YYNotificationReasonComment,
    YYNotificationReasonHandleRemoved
};

typedef NS_ENUM(NSUInteger, YYThingType)
{
    YYThingTypeComment = 1,
    YYThingTypeYak,
    YYThingTypeInfo
};


NS_ASSUME_NONNULL_BEGIN

@interface YYNotification : YYThing

@property (nonatomic, readonly) BOOL     unread;
@property (nonatomic, readonly, nullable) NSString *summary;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) NSString *subject;

@property (nonatomic, readonly) YYNotificationReason reason;
@property (nonatomic, readonly, nullable) NSString *replyIdentifier;

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) id created;
@property (nonatomic, readonly, nullable) NSString  *key;
@property (nonatomic, readonly, nullable) NSString  *hashKey;
@property (nonatomic, readonly, nullable) NSString  *navigationURLString;

@property (nonatomic, readonly) NSString *priority;
@property (nonatomic, readonly) BOOL     isNormalPriority;

@property (nonatomic, readonly) NSString *thingIdentifier;
@property (nonatomic, readonly) YYThingType thingType;

@property (nonatomic, readonly) id __v;
@property (nonatomic, readonly) id updated;
@property (nonatomic, readonly) NSString *userIdentifier;

@end

NS_ASSUME_NONNULL_END