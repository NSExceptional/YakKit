//
//  YYClient+Personal.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Personal.h"
#import "YYClient+Yaks.h"
#import "YYNotification.h"
#import "YYYak.h"
#import "YYComment.h"
@import TBURLRequestOptions;


@implementation YYClient (Personal)

#pragma mark Helper methods

- (void)getSelfYaks:(NSString *)sort callback:(YYArrayBlock)completion {
    [self getFeed:@"SELF" order:sort limit:0 after:nil callback:completion];
}

#pragma mark User data

- (void)getMyRecentYaks:(YYArrayBlock)completion {
    [self getSelfYaks:@"NEW" callback:completion];
}

- (void)getMyTopYaks:(YYArrayBlock)completion {
    [self getSelfYaks:@"TOP" callback:completion];
}

- (void)getMyRecentReplies:(YYArrayBlock)completion {
    NSString *query = ({ @" \
        query MyComments($pageLimit: Int, $cursor: String) { \
            me { \
                __typename \
                comments(first: $pageLimit, after: $cursor) { \
                    __typename \
                    edges { \
                        __typename \
                        node { \
                            __typename \
                            id \
                            text \
                            userId \
                            userEmoji \
                            userColor \
                            secondaryUserColor \
                            yak { \
                                __typename \
                                id \
                                text \
                                userId \
                            } \
                            point \
                            geohash \
                            interestAreas \
                            createdAt \
                            voteCount \
                            isOp \
                        } \
                    } \
                    pageInfo { \
                        __typename \
                        endCursor \
                        hasNextPage \
                    } \
                } \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{ @"cursor": NSNull.null, @"pageLimit": @50 } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.me.comments.edges";
        [self completeWithClass:[YYComment class] array:path response:parser completion:completion];
    }];
}

#pragma mark Notifications

// TODO: Support pagination
- (void)getNotifications:(YYArrayBlock)completion {
    // For posting the notification
    YYVoidBlock callback = completion;
    completion = ^(NSArray *collection, NSError *error) {
        [NSNotificationCenter.defaultCenter postNotificationName:kYYDidLoadNotificationsNotification object:self];
        callback(collection, error);
    };
    
    NSString *query = ({ @" \
        query AllNotifications($pageLimit: Int, $cursor: String) { \
            notifications(first: $pageLimit, after: $cursor) { \
                edges { \
                    node { \
                        id \
                        isRead \
                        message \
                        url \
                        objectType \
                        createdAt \
                        objectId \
                        attributes \
                        notificationType \
                    } \
                } \
                pageInfo { \
                    __typename \
                    endCursor \
                    hasNextPage \
                } \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{ @"cursor": NSNull.null, @"pageLimit": @30 } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.notifications.edges";
        [self completeWithClass:[YYNotification class] array:path response:parser completion:completion];
    }];
}

- (void)mark:(YYNotification *)notification read:(BOOL)read completion:(nullable YYErrorBlock)completion {
    NSDictionary *body = @{@"notificationID": notification.identifier,
                           @"parentID": notification.thingIdentifier,
                           @"status": read ? @"read" : @"unread",
                           @"userID": self.userIdentifier};
    
    [self sendNotifyBodyJSON:body endpoint:kepMarkNotification callback:completion];
}

- (void)markEach:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(nullable YYErrorBlock)completion {
    notifications = [notifications filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(YYNotification *n, id bindings) {
        return n.read != read;
    }]];
    NSDictionary *body = @{@"notificationIDs[]": [[notifications valueForKeyPath:@"@unionOfObjects.identifier"] componentsJoinedByString:@","],
                           @"status": read ? @"read" : @"unread",
                           @"userID": self.userIdentifier};
    
    [self sendNotifyBodyJSON:body endpoint:kepMarkNotificationsBatch callback:completion];
}

- (void)sendNotifyBodyJSON:(NSDictionary *)bodyJSON endpoint:(NSString *)endpoint callback:(nullable YYErrorBlock)completion {
    [self post:^(TBURLRequestBuilder *make) {
//        make.baseURL(kBaseNotifyURL).endpoint(endpoint).bodyJSON(bodyJSON);
    } callback:^(TBResponseParser *parser) {
        if (parser.error) {
            YYRunBlockP(completion, parser.error);
        } else {
            [self handleStatus:parser.JSON callback:completion];
        }
    }];
}

@end
