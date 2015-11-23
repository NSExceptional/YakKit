//
//  YYClient+Yakking.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yakking.h"

@implementation YYClient (Yakking)

#pragma mark Posting / removing yaks

- (void)postYak:(NSString *)title handle:(nullable NSString *)handle completion:(nullable ErrorBlock)completion {
    
}

- (void)deleteYak:(YYYak *)yak completion:(nullable ErrorBlock)completion {
    
}

#pragma mark Posting / removing comments

- (void)postComment:(NSString *)body toYak:(YYYak *)yak completion:(nullable ErrorBlock)completion {
    
}

- (void)deleteComment:(YYComment *)comment completion:(nullable ErrorBlock)completion {
    
}

#pragma mark Voting

- (void)upvote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion {
    
}

- (void)downvote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion {
    
}

- (void)removeVote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion {
    
}

@end
