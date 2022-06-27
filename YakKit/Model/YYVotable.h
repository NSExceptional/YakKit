//
//  YYVotable.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"

#ifndef UIKIT_EXTERN
    #define UIColor NSObject
#endif

@class CLLocation;

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

@property (nonatomic, readonly          ) NSString *text;
@property (nonatomic, readonly          ) NSString *authorIdentifier;
@property (nonatomic, readonly, nullable) NSString *emoji;
@property (nonatomic, readonly, nullable) UIColor *color;
@property (nonatomic, readonly, nullable) UIColor *colorSecondary;

@property (nonatomic, readonly, nullable) NSString *colorHex;
@property (nonatomic, readonly, nullable) NSString *colorSecondaryHex;

@property (nonatomic) NSInteger    score;
@property (nonatomic) YYVoteStatus voteStatus;

@property (nonatomic, readonly) NSDate *created;

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSString *geohash;
@property (nonatomic, readonly) NSString *locationName;
@property (nonatomic, readonly) NSArray<NSString *> *interestAreas;

@property (nonatomic, readonly) BOOL isClaimed;
@property (nonatomic, readonly) BOOL isIncognito;
@property (nonatomic, readonly) BOOL isMine;
@property (nonatomic, readonly) BOOL isReported;

/// Use this however you want to flag or identify objects.
@property (nonatomic) NSInteger tag;

#pragma mark Deprecated
@property (nonatomic, readonly          ) NSString *username;

@end

NS_ASSUME_NONNULL_END
