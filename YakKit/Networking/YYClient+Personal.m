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

- (void)getSelfYaksAfter:(nullable NSString *)lastItem
                    sort:(NSString *)sort
                callback:(YYArrayPageBlock)completion {
    [self getFeed:@"SELF" order:sort limit:0 after:nil callback:completion];
}

#pragma mark User data

- (void)objc_getMyRecentYaksAfter:(nullable NSString *)lastItem completion:(YYArrayPageBlock)completion {
    [self getSelfYaksAfter:lastItem sort:@"NEW" callback:completion];
}

- (void)objc_getMyTopYaksAfter:(nullable NSString *)lastItem completion:(YYArrayPageBlock)completion {
    [self getSelfYaksAfter:lastItem sort:@"TOP" callback:completion];
}

- (void)objc_getMyRecentRepliesAfter:(nullable NSString *)lastItem completion:(YYArrayPageBlock)completion {
    NSString *query = ({ @" \
        query MyComments($pageLimit: Int, $cursor: String) { \
            me { \
                comments(first: $pageLimit, after: $cursor) { \
                    edges { \
                        node { \
                            yak { \
                                id \
                                text \
                                userId \
                            } \
                            id \
                            text \
                            userId \
                            userEmoji \
                            userColor \
                            secondaryUserColor \
                            geohash \
                            interestAreas \
                            createdAt \
                            isMine \
                            myVote \
                            voteCount \
                            isOp \
                        } \
                    } \
                    pageInfo { \
                        endCursor \
                        hasNextPage \
                    } \
                } \
            } \
        } \
    "; });
    
    id cursor = lastItem ?: NSNull.null;
    [self graphQL:query variables:@{ @"cursor": cursor, @"pageLimit": @100 } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.me.comments";
        [self completeWithPaginatedClass:YYComment.self dataPath:path response:parser completion:completion];
    }];
}

#pragma mark Notifications

- (void)getNotificationsAfter:(nullable NSString *)lastItem completion:(YYArrayPageBlock)completion {
    // For posting the notification
    YYArrayPageBlock callback = completion;
    completion = ^(NSArray *collection, NSString *cursor, NSError *error) {
        [NSNotificationCenter.defaultCenter postNotificationName:kYYDidLoadNotificationsNotification object:self];
        callback(collection, cursor, error);
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
                    endCursor \
                    hasNextPage \
                } \
            } \
        } \
    "; });
    
    id cursor = lastItem ?: NSNull.null;
    [self graphQL:query variables:@{ @"cursor": cursor, @"pageLimit": @150 } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.notifications";
        [self completeWithPaginatedClass:YYNotification.self dataPath:path response:parser completion:completion];
    }];
}

- (void)clearUnreadNotifications:(YYErrorBlock)completion {
    // For posting the notification
    YYErrorBlock callback = completion;
    completion = ^(NSError *error) {
        [NSNotificationCenter.defaultCenter postNotificationName:kYYDidLoadNotificationsNotification object:self];
        
        if (callback) {
            callback(error);
        }
    };
    
    NSString *query = ({ @" \
        mutation MarkAllNotificationsAsRead { \
            markAllNotificationsAsRead { \
                notifications { \
                    edges { node { id isRead } } \
                } \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{} callback:^(TBResponseParser *parser) {
        [self completeWithResponse:parser completion:completion];
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

}

@end
