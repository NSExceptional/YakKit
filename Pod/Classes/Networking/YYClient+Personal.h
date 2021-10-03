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
- (void)getMyRecentYaks:(YYArrayBlock)completion;
- (void)getMyTopYaks:(YYArrayBlock)completion;
- (void)getMyRecentReplies:(YYArrayBlock)completion;

#pragma mark Notifications
/// Will post kYYDidLoadNotificationsNotification on success before calling the completion block.
- (void)getNotifications:(YYArrayBlock)completion;
- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable YYErrorBlock)completion;
- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable YYErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END
