//
//  YYClient+Yakking.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"
#import "YYVotable.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Yakking)

#pragma mark Posting
- (void)postYak:(NSString *)title
    anonymously:(BOOL)anon
     completion:(YYResponseBlock)completion NS_SWIFT_NAME(objc_postYak(_:_:_:));

/// Gives back the posted comment
- (void)postComment:(NSString *)body
              toYak:(YYYak *)yak
         completion:(YYResponseBlock)completion NS_SWIFT_NAME(objc_postComment(_:to:_:));

#pragma mark Deleting
- (void)deleteYak:(YYYak *)thing completion:(nullable YYErrorBlock)completion;
- (void)deleteComment:(YYComment *)thing completion:(nullable YYErrorBlock)completion;

#pragma mark Voting
- (void)upvote:(YYVotable *)yakOrComment completion:(nullable YYErrorBlock)completion;
- (void)downvote:(YYVotable *)yakOrComment completion:(nullable YYErrorBlock)completion;
- (void)removeVote:(YYVoteStatus)vote from:(YYVotable *)yakOrComment completion:(nullable YYErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END
