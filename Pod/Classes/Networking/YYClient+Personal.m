//
//  YYClient+Personal.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Personal.h"
#import "YYNotification.h"
#import "YYYak.h"
#import "NSArray+YakKit.h"

@implementation YYClient (Personal)

#pragma mark Helper methods

- (void)getUserData:(NSString *)endpoint callback:(ArrayBlock)completion {
    [self get:URL(self.baseURLForRegion, endpoint) callback:^(id object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

#pragma mark User data

- (void)getMyRecentYaks:(ArrayBlock)completion {
    [self getUserData:kepGetMyRecentYaks callback:completion];
}

- (void)getMyTopYaks:(ArrayBlock)completion {
    [self getUserData:kepGetMyTopYaks callback:completion];
}

- (void)getMyRecentReplies:(ArrayBlock)completion {
    [self getUserData:kepGetMyRecentReplies callback:completion];
}

#pragma mark Notifications

- (void)getNotifications:(ArrayBlock)completion {
    // For posting the notification
    completion = ^(NSArray *collection, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kYYDidLoadNotificationsNotification object:self];
        completion(collection, error);
    };
    NSString *endpoint = [NSString stringWithFormat:kepGetNotifications_user, self.userIdentifier];
    [self get:URL(kBaseNotifyURL, endpoint) callback:^(NSDictionary *object, NSError *error) {
        [self completeWithClass:[YYNotification class] jsonArray:object[@"data"] error:error completion:completion];
    }];
}

- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable ErrorBlock)completion {
    NSDictionary *query = @{@"notificationID": notification.identifier,
                            @"parentID": self.userIdentifier, // TODO
                            @"status": read ? @"read" : @"unread",
                            @"userID": self.userIdentifier};
    [self postTo:URL(kBaseNotifyURL, kepMarkNotification) params:[self generalParams:nil] httpBodyParams:query sign:YES callback:^(NSDictionary *json, NSError *error) {
        if (error) {
            YYRunBlockP(completion, error);
        } else {
            [self handleStatus:json callback:completion];
        }
    }];
}

- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable ErrorBlock)completion {
    NSDictionary *query = @{@"notificationIDs": [[notifications valueForKeyPath:@"@unionOfObjects.identifier"] JSONString],
                            @"status": read ? @"read" : @"unread",
                            @"userID": self.userIdentifier};
    [self postTo:URL(kBaseNotifyURL, kepMarkNotificationsBatch) params:[self generalParams:nil] httpBodyParams:query sign:YES callback:^(NSDictionary *json, NSError *error) {
        if (error) {
            YYRunBlockP(completion, error);
        } else {
            [self handleStatus:json callback:completion];
        }
    }];
}

@end
