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

- (void)postYak:(NSString *)title useHandle:(BOOL)handle completion:(nullable ErrorBlock)completion {
    NSDictionary *query = @{@"hidePin": @"1",
                            @"lat": @(self.location.coordinate.latitude),
                            @"long": @(self.location.coordinate.longitude),
                            @"message": title,
                            @"useNickname": @((int)handle),
                            @"userID": self.userIdentifier};
    [self postTo:URL(self.baseURLForRegion, kepPostYak) query:[self generalQuery:nil] body:query sign:YES callback:^(id object, NSError *error) {
        YYRunBlockP(completion, error);
    }];
}

- (void)postComment:(NSString *)body toYak:(YYYak *)yak useHandle:(BOOL)handle completion:(nullable ErrorBlock)completion {
    NSDictionary *query = @{@"comment": body,
                            @"herdID": @"0",
                            @"messageID": yak.identifier,
                            @"useNickname": @((int)handle),
                            @"userID": self.userIdentifier};
    [self postTo:URL(self.baseURLForRegion, kepPostComment) query:[self generalQuery:nil] body:query sign:YES callback:^(id object, NSError *error) {
        YYRunBlockP(completion, error);
    }];
}

#pragma mark Deleting

// Uses YYComment here on purpose
- (void)deleteYakOrComment:(YYComment *)thing completion:(nullable ErrorBlock)completion {
    NSDictionary *params;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        params = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepDeleteYak;
    } else {
        params = [self generalQuery:@{@"commentID": thing.identifier,
                                       @"messageID": thing.yakIdentifier}];
        endpoint = kepDeleteComment;
    }
    
    [self get:URL(self.baseURLForRegion, endpoint) query:params sign:YES callback:^(id object, NSError *error) {
        YYRunBlockP(completion, error);
    }];
}

#pragma mark Voting

- (void)upvote:(YYVotable *)thing completion:(nullable ErrorBlock)completion {
    if (thing.voteStatus == YYVoteStatusUpvoted) { YYRunBlockP(completion, nil); return; }
    
    NSDictionary *params;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        params = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepToggleUpvoteYak;
    } else {
        params = [self generalQuery:@{@"commentID": thing.identifier}];
        endpoint = kepToggleUpvoteComment;
    }
    
    [self get:URL(self.baseURLForRegion, endpoint) query:params sign:YES callback:^(id object, NSError *error) {
        if (!error) { [thing setValue:@(YYVoteStatusUpvoted) forKey:@"voteStatus"]; }
        YYRunBlockP(completion, error);
    }];
}

- (void)downvote:(YYVotable *)thing completion:(nullable ErrorBlock)completion {
    if (thing.voteStatus == YYVoteStatusDownvoted) { YYRunBlockP(completion, nil); return; }
    
    NSDictionary *params;
    NSString *endpoint;
    if ([thing isKindOfClass:[YYYak class]]) {
        params = [self generalQuery:@{@"messageID": thing.identifier}];
        endpoint = kepToggleDownvoteYak;
    } else {
        params = [self generalQuery:@{@"commentID": thing.identifier}];
        endpoint = kepToggleDownvoteComment;
    }
    
    [self get:URL(self.baseURLForRegion, endpoint) query:params sign:YES callback:^(id object, NSError *error) {
        if (!error) { [thing setValue:@(YYVoteStatusDownvoted) forKey:@"voteStatus"]; }
        YYRunBlockP(completion, error);
    }];
}

- (void)removeVote:(YYVotable *)thing completion:(nullable ErrorBlock)completion {
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
    
    NSDictionary *params = [self generalQuery:@{idName: thing.identifier}];
    [self get:URL(self.baseURLForRegion, endpoint) query:params sign:YES callback:^(id object, NSError *error) {
        if (!error) { [thing setValue:@(YYVoteStatusNone) forKey:@"voteStatus"]; }
        YYRunBlockP(completion, error);
    }];
}

@end
