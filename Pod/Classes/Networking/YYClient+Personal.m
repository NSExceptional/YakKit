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
#import "NSArray+Networking.h"


@implementation YYClient (Personal)

#pragma mark Helper methods

- (void)getUserData:(NSString *)endpoint callback:(ArrayBlock)completion {
    [self get:^(TBURLRequestBuilder *make) { make.endpoint(endpoint); }
     callback:^(TBResponseParser *parser) {
         [self completeWithClass:[YYYak class] jsonArray:parser.JSON[@"messages"] error:parser.error completion:completion];
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
    VoidBlock callback = completion;
    completion = ^(NSArray *collection, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kYYDidLoadNotificationsNotification object:self];
        callback(collection, error);
    };
    
    NSString *endpoint = [NSString stringWithFormat:kepGetNotifications_user, self.userIdentifier];
    [self get:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseNotifyURL).endpoint(endpoint);
    } callback:^(TBResponseParser *parser) {
        [self completeWithClass:[YYNotification class] jsonArray:parser.JSON[@"data"] error:parser.error completion:completion];
    }];
}

- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable ErrorBlock)completion {
    NSDictionary *body = @{@"notificationID": notification.identifier,
                           @"parentID": notification.thingIdentifier,
                           @"status": read ? @"read" : @"unread",
                           @"userID": self.userIdentifier};
    
    [self sendNotifyBodyJSON:body endpoint:kepMarkNotification callback:completion];
}

- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable ErrorBlock)completion {
    notifications = [notifications filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(YYNotification *n, id bindings) {
        return n.unread != read;
    }]];
    NSDictionary *body = @{@"notificationIDs[]": [[notifications valueForKeyPath:@"@unionOfObjects.identifier"] componentsJoinedByString:@","],
                           @"status": read ? @"read" : @"unread",
                           @"userID": self.userIdentifier};
    
    [self sendNotifyBodyJSON:body endpoint:kepMarkNotificationsBatch callback:completion];
}

- (void)sendNotifyBodyJSON:(NSDictionary *)bodyJSON endpoint:(NSString *)endpoint callback:(nullable ErrorBlock)completion {
    [self post:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseNotifyURL).endpoint(endpoint).bodyJSON(bodyJSON);
    } callback:^(TBResponseParser *parser) {
        if (parser.error) {
            YYRunBlockP(completion, parser.error);
        } else {
            [self handleStatus:parser.JSON callback:completion];
        }
    }];
}

@end
