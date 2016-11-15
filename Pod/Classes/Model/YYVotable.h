//
//  YYVotable.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


typedef NS_ENUM(NSInteger, YYVoteStatus)
{
    YYVoteStatusDownvoted = -1,
    YYVoteStatusNone = 0,
    YYVoteStatusUpvoted = 1
};


NS_ASSUME_NONNULL_BEGIN

@interface YYVotable : YYThing

- (NSComparisonResult)compareScore:(YYVotable *)votable;
- (NSComparisonResult)compareCreated:(YYVotable *)votable;

@property (nonatomic, readonly, nullable) NSString *personaIdentifier;
@property (nonatomic, readonly, nullable) NSString *username;

@property (nonatomic, readonly) NSInteger    score;
@property (nonatomic, readonly) YYVoteStatus voteStatus;

@property (nonatomic, readonly) NSDate *created;
@property (nonatomic, readonly) NSDate *gmt;

@property (nonatomic, readonly) id deliveryIdentifier;

/// Use this however you want to flag or identify objects.
@property (nonatomic) NSInteger tag;

@end

NS_ASSUME_NONNULL_END
