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


@implementation YYClient (Yakking)

#pragma mark Posting

- (void)postYak:(NSString *)title useHandle:(BOOL)handle completion:(nullable YYErrorBlock)completion {
    NSDictionary *body = @{@"hidePin": @"1",
                           @"lat": @(self.location.coordinate.latitude),
                           @"long": @(self.location.coordinate.longitude),
                           @"message": title,
                           @"useNickname": @((int)handle),
                           @"userID": self.userIdentifier};
    
    [self post:^(TBURLRequestBuilder *make) {
        make.endpoint(kepPostYak).bodyJSONFormString(body);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

- (void)postComment:(NSString *)body toYak:(YYYak *)yak useHandle:(BOOL)handle completion:(nullable YYErrorBlock)completion {
    NSDictionary *bodyForm = @{@"comment": body,
                               @"herdID": @"0",
                               @"messageID": yak.identifier,
                               @"useNickname": @((int)handle),
                               @"userID": self.userIdentifier};
    
    [self post:^(TBURLRequestBuilder *make) {
        make.endpoint(kepPostComment).bodyJSONFormString(bodyForm);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

#pragma mark Deleting

// Uses YYComment here on purpose
- (void)deleteYakOrComment:(YYComment *)thing completion:(nullable YYErrorBlock)completion {
    NSDictionary *query;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        query = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepDeleteYak;
    } else {
        query = [self generalQuery:@{@"commentID": thing.identifier,
                                     @"messageID": thing.yakIdentifier}];
        endpoint = kepDeleteComment;
    }
    
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint).queries(query);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

#pragma mark Voting

- (void)upvote:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    if (thing.voteStatus == YYVoteStatusUpvoted) { YYRunBlockP(completion, nil); return; }
    
    NSDictionary *query;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        query = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepToggleUpvoteYak;
    } else {
        query = [self generalQuery:@{@"commentID": thing.identifier}];
        endpoint = kepToggleUpvoteComment;
    }
    
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint).queries(query);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

- (void)downvote:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    if (thing.voteStatus == YYVoteStatusDownvoted) { YYRunBlockP(completion, nil); return; }
    
    NSDictionary *query;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        query = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepToggleDownvoteYak;
    } else {
        query = [self generalQuery:@{@"commentID": thing.identifier}];
        endpoint = kepToggleDownvoteComment;
    }
    
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint).queries(query);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

- (void)removeVote:(YYVotable *)thing completion:(nullable YYErrorBlock)completion {
    NSString *idName;
    NSString *endpoint;
    
    if ([thing isKindOfClass:[YYYak class]]) {
        idName = @"messageID";
    } else {
        idName = @"commentID";
    }
    
    switch (thing.voteStatus) {
        case YYVoteStatusDownvoted: {
            if ([thing isKindOfClass:[YYYak class]]) {
                endpoint = kepToggleDownvoteYak;
            } else {
                endpoint = kepToggleDownvoteComment;
            }
            break;
        }
        case YYVoteStatusNone: {
            YYRunBlockP(completion, nil); return;
            break;
        }
        case YYVoteStatusUpvoted: {
            if ([thing isKindOfClass:[YYYak class]]) {
                endpoint = kepToggleUpvoteYak;
            } else {
                endpoint = kepToggleUpvoteComment;
            }
            break;
        }
    }
    
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint).queries([self generalQuery:@{idName: thing.identifier}]);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

@end
