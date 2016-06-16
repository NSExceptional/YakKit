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
                            @"parentID": notification.thingIdentifier,
                            @"status": read ? @"read" : @"unread",
                            @"userID": self.userIdentifier};
    [self postTo:URL(kBaseNotifyURL, kepMarkNotification) query:[self generalQuery:nil] body:query sign:YES callback:^(NSDictionary *json, NSError *error) {
        if (error) {
            YYRunBlockP(completion, error);
        } else {
            [self handleStatus:json callback:completion];
        }
    }];
}

- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable ErrorBlock)completion {
    notifications = [notifications filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(YYNotification *n, id bindings) {
        return n.unread != read;
    }]];
    NSDictionary *query = @{@"notificationIDs[]": [[notifications valueForKeyPath:@"@unionOfObjects.identifier"] componentsJoinedByString:@","],
                            @"status": read ? @"read" : @"unread",
                            @"userID": self.userIdentifier};
    [self postTo:URL(kBaseNotifyURL, kepMarkNotificationsBatch) query:[self generalQuery:nil] body:query sign:YES callback:^(NSDictionary *json, NSError *error) {
        if (error) {
            YYRunBlockP(completion, error);
        } else {
            [self handleStatus:json callback:completion];
        }
    }];
}

@end
