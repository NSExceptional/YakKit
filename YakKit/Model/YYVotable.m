//
//  YYVotable.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"
#import "YYModel+Private.h"

struct CLLocationCoordinate2D {
    double latitude;
    double longitude;
};
typedef struct CLLocationCoordinate2D CLLocationCoordinate2D;

@interface CLLocation : NSObject <NSCopying, NSSecureCoding>
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;
@property(readonly, nonatomic) CLLocationCoordinate2D coordinate;
@end

@implementation YYVotable

+ (NSDictionary *)JSONKeyPathsByPropertyKey { SetCoder(YYVotable)
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @codingKey(identifier): @"id",
        @codingKey(authorIdentifier): @"userId",
        @codingKey(created): @"createdAt",
        
        @codingKey(location): @"point",
        
        @codingKey(score): @"voteCount",
        @codingKey(voteStatus): @"myVote",
        
        @codingKey(emoji): @"userEmoji",
        @codingKey(colorHex): @"userColor",
        @codingKey(colorSecondaryHex): @"secondaryUserColor",
    }];
}

- (NSString *)locationName {
    return self.interestAreas.firstObject;
}

+ (NSValueTransformer *)voteStatusJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *status, BOOL *success, NSError **error) {
        return @{
            @"DOWN": @(YYVoteStatusDownvoted),
            @"NONE": @(YYVoteStatusNone),
            @"UP":   @(YYVoteStatusUpvoted),
        }[status];
    } reverseBlock:^id(NSNumber *status, BOOL *success, NSError **error) {
        return @{
            @(YYVoteStatusDownvoted): @"DOWN",
            @(YYVoteStatusNone):      @"NONE",
            @(YYVoteStatusUpvoted):   @"UP",
        }[status];
    }];
}

+ (NSValueTransformer *)locationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *point, BOOL *success, NSError **error) {
        NSArray<NSNumber *> *coordinates = point[@"coordinates"];
        return [[NSClassFromString(@"CLLocation") alloc]
            initWithLatitude:coordinates[1].doubleValue longitude:coordinates[0].doubleValue
        ];
    }
    reverseBlock:^id(CLLocation *location, BOOL *success, NSError **error) {
        // Longitude first, then latitude
        return @{ @"coordinates": @[@(location.coordinate.latitude), @(location.coordinate.longitude)] };
    }];
}

+ (NSValueTransformer *)createdJSONTransformer { return [self yy_stringDateTransformer]; }

- (NSComparisonResult)compareScore:(YYVotable *)votable {
    if (self.score < votable.score) {
        return NSOrderedAscending;
    } else if (self.score == votable.score) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

- (NSComparisonResult)compareCreated:(YYVotable *)votable {
    return [self.created compare:votable.created];
}


@end
