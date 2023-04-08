//
//  YYClient+Yaks.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yaks.h"
#import "YYYak.h"
#import "YYComment.h"
#import "YYPeekLocation.h"
#import "YYNotification.h"
@import TBURLRequestOptions;

@implementation YYClient (Yaks)

#pragma mark Getting yak feeds

- (void)getFeed:(NSString *)type order:(NSString *)order
          limit:(NSInteger)limit after:(NSString *)lastYakID
       callback:(YYArrayPageBlock)completion {
    NSParameterAssert(type); NSParameterAssert(order);
    
    NSString *query = ({ @" \
        query Feed($feedType: FeedType, $order: FeedOrder, $pageLimit: Int, $cursor: String, $point: FixedPointScalar) { \
            feed( \
                feedType: $feedType \
                feedOrder: $order \
                first: $pageLimit \
                after: $cursor \
                point: $point \
            ) { \
                edges { \
                    node { \
                        id \
                        commentCount \
                        createdAt \
                        interestAreas \
                        isClaimed \
                        isIncognito \
                        isMine \
                        myVote \
                        secondaryUserColor \
                        text \
                        userColor \
                        userEmoji \
                        userId \
                        voteCount \
                    } \
                } \
                pageInfo { \
                    endCursor \
                    hasNextPage \
                } \
            } \
        } \
    "; });
    
    if (!limit) limit = 50;
    
    NSDictionary *variables = @{
        @"feedType": type,
        @"order": order,
        @"pageLimit": @(limit),
        @"cursor": lastYakID ?: NSNull.null,
        @"point": self.graphQLLocation,
    };
    
    return [self graphQL:query variables:variables callback:^(TBResponseParser *parser) {
        [self completeWithPaginatedClass:YYYak.self dataPath:@"data.feed" response:parser completion:completion];
    }];
}

- (void)getLocalYaksAfter:(NSString *)lastYak completion:(YYArrayPageBlock)completion {
    [self getFeed:@"LOCAL" order:@"NEW" limit:0 after:lastYak callback:completion];
}

- (void)getLocalHotYaksAfter:(NSString *)lastYak completion:(YYArrayPageBlock)completion {
    [self getFeed:@"LOCAL" order:@"HOT" limit:0 after:lastYak callback:completion];
}

- (void)getLocalTopYaksAfter:(NSString *)lastYak completion:(YYArrayPageBlock)completion {
    [self getFeed:@"LOCAL" order:@"TOP" limit:0 after:lastYak callback:completion];
}

#pragma mark Getting info about a yak

- (void)getYak:(YYNotification *)notification completion:(YYResponseBlock)completion {
    NSString *query = ({ @" \
        query Yak($id: ID!) { \
            yak(id: $id) { \
                id \
                text \
                userEmoji \
                userColor \
                secondaryUserColor \
                geohash \
                interestAreas \
                createdAt \
                isMine \
                myVote \
                commentCount \
                voteCount \
                userId \
                isIncognito \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{@"id": notification.thingIdentifier} callback:^(TBResponseParser *parser) {
        [self completeWithClass:YYYak.self object:@"data.yak" response:parser completion:completion];
    }];
}

- (void)getCommentsForYak:(YYYak *)yak after:(NSString *)lastCommentID completion:(YYArrayPageBlock)completion {
    NSString *query = ({ @" \
        query YakComments($id: ID!, $pageLimit: Int, $cursor: String) { \
            yak(id: $id) { \
                id \
                comments(first: $pageLimit, after: $cursor) { \
                    edges { \
                        node { \
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
                            yak { id } \
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
    
    [self graphQL:query variables:@{
        @"cursor": lastCommentID ?: NSNull.null,
        @"pageLimit": @50,
        @"id": yak.identifier
    } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.yak.comments";
        [self completeWithPaginatedClass:YYComment.self dataPath:path response:parser completion:completion];
    }];
}

@end
