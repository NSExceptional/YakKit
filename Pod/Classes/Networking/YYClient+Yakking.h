//
//  YYClient+Yakking.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Yakking)

#pragma mark Posting
- (void)postYak:(NSString *)title useHandle:(BOOL)handle completion:(nullable ErrorBlock)completion;
- (void)postComment:(NSString *)body toYak:(YYYak *)yak useHandle:(BOOL)handle completion:(nullable ErrorBlock)completion;

#pragma mark Deleting
- (void)deleteYakOrComment:(YYVotable *)thing completion:(nullable ErrorBlock)completion;

#pragma mark Voting
- (void)upvote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion;
- (void)downvote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion;
- (void)removeVote:(YYVotable *)yakOrComment completion:(nullable ErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END
