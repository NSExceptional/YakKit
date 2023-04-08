//
//  YYClient+Yakking.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yakking.h"
#import "YYYak.h"
#import "YYComment.h"
#import "YYUser.h"
@import FirebaseFirestore;

NSString * YYCollectionForVoteStatus(YYVoteStatus vote) {
    switch (vote) {
        case YYVoteStatusUpvoted:
            return @"Upvoters";
        case YYVoteStatusDownvoted:
            return @"Downvoters";
        default:
            return nil;
    }
}

@interface YYVotable (Voting)
- (NSString *)documentPathForVoteStatus:(YYVoteStatus)vote user:(NSString *)userID;
@end

@implementation YYYak (Voting)
- (NSString *)documentPathForVoteStatus:(YYVoteStatus)vote user:(NSString *)userID {
    NSString *collection = YYCollectionForVoteStatus(vote);
    return @[@"Yaks", self.identifier, collection, userID];
}
@end
@implementation YYComment (Voting)
- (NSString *)documentPathForVoteStatus:(YYVoteStatus)vote user:(NSString *)userID {
    NSString *collection = YYCollectionForVoteStatus(vote);
    return @[@"Yaks", self.yakIdentifier, @"Comments", self.identifier, collection, userID];
}
@end

@implementation YYClient (Yakking)

#pragma mark Posting

- (void)postYak:(NSString *)title
    anonymously:(BOOL)anon
     completion:(YYResponseBlock)completion {
    NSParameterAssert(title); NSParameterAssert(completion);
    
    NSString *query = ({ @" \
        mutation CreateYak($input: CreateYakInput!) { \
            createYak(input: $input) { \
                errors { \
                    code \
                    field \
                    message \
                } \
                yak { \
                    id \
                    text \
                    userEmoji \
                    userColor \
                    secondaryUserColor \
                    interestAreas \
                    createdAt \
                    isMine \
                    userId \
                    isIncognito \
                } \
            } \
        } \
    "; });
    
    NSDictionary *data = @{
        @"isIncognito": @(anon),
        @"interestAreas": @[],
        @"point": self.graphQLLocation,
        @"userColor": self.currentUser.color,
        @"secondaryUserColor": self.currentUser.secondaryColor,
        @"userEmoji": self.currentUser.emoji,
        @"text": title,
        @"videoId": @"",
    };
    
    [self graphQL:query variables:@{ @"input": data } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.createYak.yak";
        [self completeWithClass:YYYak.self object:path response:parser completion:completion];
    }];
}

- (void)postComment:(NSString *)body toYak:(YYYak *)yak completion:(YYResponseBlock)completion {
    NSParameterAssert(body); NSParameterAssert(completion);
    
    NSParameterAssert(self.currentUser.color);
    NSParameterAssert(self.currentUser.secondaryColor);
    NSParameterAssert(self.currentUser.emoji);
    NSParameterAssert(self.graphQLLocation);
    
    NSString *query = ({ @" \
        mutation CreateComment($input: CreateCommentInput!) { \
            createComment(input: $input) { \
                errors { \
                    code \
                    field \
                    message \
                } \
                comment { \
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
        } \
    "; });
    
    NSDictionary *data = @{
        @"yakId": yak.identifier,
        @"interestAreas": @[],
        @"point": self.graphQLLocation,
        @"userColor": self.currentUser.color,
        @"secondaryUserColor": self.currentUser.secondaryColor,
        @"userEmoji": self.currentUser.emoji,
        @"text": body,
    };
    
    [self graphQL:query variables:@{ @"input": data } callback:^(TBResponseParser *parser) {
        NSString *path = @"data.createComment.comment";
        [self completeWithClass:YYComment.self object:path response:parser completion:completion];
    }];
}

#pragma mark Deleting

// Uses YYComment here on purpose
- (void)deleteYak:(YYYak *)thing completion:(YYErrorBlock)completion {
    NSString *query = ({ @" \
        mutation DeleteYak($yakid: ID!) { \
            removeYak(input: { id: $yakid }) { \
                errors { \
                    code \
                    field \
                    message \
                } \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{ @"yakid": thing.identifier } callback:^(TBResponseParser *parser) {
        [self completeWithResponse:parser completion:completion];
    }];
}

- (void)deleteComment:(YYComment *)thing completion:(YYErrorBlock)completion {
    NSString *query = ({ @" \
        mutation DeleteComment($commentid: ID!, $yakid: ID!) { \
            removeComment(input: { id: $commentid, yakId: $yakid }) { \
                errors { \
                    code \
                    field \
                    message \
                } \
            } \
        } \
    "; });
    
    NSDictionary *data = @{ @"commentid": thing.identifier, @"yakid": thing.yakIdentifier };
    [self graphQL:query variables:data callback:^(TBResponseParser *parser) {
        [self completeWithResponse:parser completion:completion];
    }];
}

#pragma mark Voting

- (void)setVote:(NSString *)status on:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    NSString *query = ({ @" \
        mutation Vote($input: VoteInput!) { \
            vote(input: $input) { \
                errors { \
                    code \
                    field \
                    message \
                } \
            } \
        } \
    "; });
    
    NSDictionary *data = @{ @"vote": status, @"instance": thing.identifier };
    [self graphQL:query variables:@{ @"input": data } callback:^(TBResponseParser *parser) {
        [self completeWithResponse:parser completion:completion];
    }];
}

- (void)upvote:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    [self setVote:@"UP" on:thing completion:completion];
}

- (void)downvote:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    [self setVote:@"DOWN" on:thing completion:completion];
}

- (void)removeVote:(YYVoteStatus)vote from:(YYVotable *)thing completion:(YYErrorBlock)completion {
    [self setVote:@"NONE" on:thing completion:completion];
}

@end
