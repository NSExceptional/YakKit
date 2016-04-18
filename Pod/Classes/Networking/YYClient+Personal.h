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
- (void)getMyRecentYaks:(ArrayBlock)completion;
- (void)getMyTopYaks:(ArrayBlock)completion;
- (void)getMyRecentReplies:(ArrayBlock)completion;

#pragma mark Notifications
- (void)getNotifications:(ArrayBlock)completion;
- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable ErrorBlock)completion;
- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable ErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END
