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
          limit:(NSInteger)limit after:(NSString *)lastYak
       callback:(YYArrayBlock)completion {
    NSString *query = ({ @" \
        query Feed($feedType: FeedType, $order: order, $pageLimit: Int, $cursor: String, $point: FixedPointScalar) { \
            feed( \
                feedType: $feedType \
                order: $order \
                first: $pageLimit \
                after: $cursor \
                point: $point \
            ) { \
                __typename \
                edges { \
                    __typename \
                    node { \
                        __typename \
                        commentCount \
                        createdAt \
                        id \
                        isClaimed \
                        isIncognito \
                        isMine \
                        myVote \
                        point \
                        secondaryUserColor \
                        text \
                        userColor \
                        userEmoji \
                        userId \
                        voteCount \
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
    
    if (!limit) limit = 50;
    
    CLLocationCoordinate2D location = self.location.coordinate;
    NSString *point = [NSString stringWithFormat:@"POINT(%@, %@)", @(location.latitude), @(location.longitude)];
    NSDictionary *variables = @{
        @"feedType": type,
        @"order": order,
        @"pageLimit": @(limit),
        @"cursor": NSNull.null,
        @"point": point,
    };
    
    return [self graphQL:query variables:variables callback:^(TBResponseParser *parser) {
        [self completeWithClass:[YYYak class] array:@"messages.feed.edges" response:parser completion:completion];
    }];
}

- (void)getLocalYaks:(YYArrayBlock)completion {
    [self getFeed:@"LOCAL" order:@"NEW" limit:0 after:nil callback:completion];
}

- (void)getLocalHotYaks:(YYArrayBlock)completion {
    [self getFeed:@"LOCAL" order:@"HOT" limit:0 after:nil callback:completion];
}

- (void)getLocalTopYaks:(YYArrayBlock)completion {
    [self getFeed:@"LOCAL" order:@"TOP" limit:0 after:nil callback:completion];
}

#pragma mark Getting info about a yak

- (void)getYak:(YYNotification *)notification completion:(YYResponseBlock)completion {
    NSString *query = ({ @" \
        query Yak($id: ID!) { \
            yak(id: $id) { \
                __typename \
                id \
                text \
                userEmoji \
                userColor \
                secondaryUserColor \
                point \
                geohash \
                interestAreas \
                createdAt \
                commentCount \
                voteCount \
                userId \
                isIncognito \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{@"id": notification.thingIdentifier} callback:^(TBResponseParser *parser) {
        [self completeWithClass:[YYYak class] object:@"data.yak" response:parser completion:completion];
    }];
}

// TODO: Support pagination
- (void)getCommentsForYak:(YYYak *)yak completion:(YYArrayBlock)completion {
    NSString *query = ({ @" \
        query YakComments($id: ID!, $pageLimit: Int, $cursor: String) { \
            yak(id: $id) { \
                __typename \
                id \
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
    
    [self graphQL:query variables:@{
        @"cursor": NSNull.null,
        @"pageLimit": @50,
        @"id": yak.identifier
    } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.yak.comments.edges";
        [self completeWithClass:[YYComment class] array:path response:parser completion:completion];
    }];
}

@end
