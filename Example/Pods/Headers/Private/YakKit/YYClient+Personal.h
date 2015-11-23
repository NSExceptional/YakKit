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

#pragma mark Getting user data
- (void)getNotifications:(ArrayBlock)completion;
- (void)getMyRecentYaks:(ArrayBlock)completion;
- (void)getMyTopYaks:(ArrayBlock)completion;
- (void)getMyRecentReplies:(ArrayBlock)completion;

#pragma mark Viewing notifications
- (void)mark:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable DictionaryBlock)completion;

@end

NS_ASSUME_NONNULL_END
