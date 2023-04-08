//
//  YYClient+Personal.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Personal)

#pragma mark User data
- (void)objc_getMyRecentYaksAfter:(nullable NSString *)lastYak completion:(YYArrayPageBlock)completion;
- (void)objc_getMyTopYaksAfter:(nullable NSString *)lastYak completion:(YYArrayPageBlock)completion;
- (void)objc_getMyRecentRepliesAfter:(nullable NSString *)lastComment completion:(YYArrayPageBlock)completion;

#pragma mark Notifications
/// Will post kYYDidLoadNotificationsNotification on success before calling the completion block.
- (void)getNotificationsAfter:(nullable NSString *)lastNotification
                   completion:(YYArrayPageBlock)completion NS_SWIFT_NAME(objc_getNotifications(after:completion:));

- (void)clearUnreadNotifications:(YYErrorBlock)completion;
//- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable YYErrorBlock)completion;
//- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable YYErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END
