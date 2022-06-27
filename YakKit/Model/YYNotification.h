//
//  YYNotification.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


typedef NS_ENUM(NSUInteger, YYNotificationReason) {
    /// No clue
    YYNotificationReasonInfo = 1,
    /// Your yak or comment was removed
    YYNotificationReasonRemoval,
    /// New comments on a post you commented on
    YYNotificationReasonInteraction,
    /// New comments / upvotes on your yak
    YYNotificationReasonYourYak,
    /// Upvotes on your yak, converted from \c YYNotificationReasonYourYak
    YYNotificationReasonUpvotes,
};

NSString *_Nonnull YYStringFromNotificationReason(YYNotificationReason reason);

typedef NS_ENUM(NSUInteger, YYThingType) {
    /// Notification is not about a yak or comment
    YYThingTypeNull = 0,
    /// Comment removed? Or new comment?
    YYThingTypeComment,
    /// For anything to do with your yaks, or new comments on another yak
    YYThingTypeYak,
};


NS_ASSUME_NONNULL_BEGIN

@interface YYNotification : YYThing

@property (nonatomic, readonly) NSDate *created;
@property (nonatomic, readonly) YYThingType thingType;
/// The derivative of \c thingIdentifier, ie 2196f948-XXXX-XXXX-XXXX-e776b8affda1
@property (nonatomic, readonly, nullable) NSString *unencodedThingIdentifier;
/// Used for requests about the thing; ie WWFrOmZiN2I5N2ViXXXxXxXxXXxxXX04NDUzLWVhMjk4N2Y3MDA1YQ==
@property (nonatomic, readonly, nullable) NSString *thingIdentifier;

@property (nonatomic, readonly, nullable) NSString *url;

@property (nonatomic, readonly) BOOL read;
@property (nonatomic, readonly) BOOL unread;
/// The notification subject
@property (nonatomic, readonly, nonnull ) NSString *subject;
/// The content of the reply, if any
@property (nonatomic, readonly, nullable) NSString *content;
@property (nonatomic, readonly) YYNotificationReason reason;

@end

NS_ASSUME_NONNULL_END
