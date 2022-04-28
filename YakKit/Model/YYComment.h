//
//  YYComment.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYComment : YYVotable

@property (nonatomic, readonly) BOOL isOP;

@property (nonatomic, readonly) NSString *commentID;
@property (nonatomic, readonly) NSString *relevantAuthorIdentifier; // commenterUID
@property (nonatomic, readonly) NSString *yakkerUID;
@property (nonatomic, readonly) NSString *yakIdentifier; // yakID
@property (nonatomic, readonly) NSString *body; // text
@property (nonatomic, readonly) NSString *timestamp;
@property (nonatomic, readonly) NSString *yakText;
@property (nonatomic, readonly) NSString *lat;
@property (nonatomic, readonly) NSString *lng;
@property (nonatomic, readonly) NSString *color;
@property (nonatomic, readonly) NSString *emoji;
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) NSString *geohash;
@property (nonatomic, readonly) NSArray<NSString *> *interestAreas; // ["Dallas, TX"]
@property (nonatomic, readonly) NSInteger numShards;
@property (nonatomic, readonly) NSInteger voteEstimate;
@property (nonatomic, readonly) BOOL deleted;
@property (nonatomic, readonly) BOOL hate;
@property (nonatomic, readonly) BOOL bullying;
@property (nonatomic, readonly) BOOL passedHiveBullying;
@property (nonatomic, readonly) BOOL passedHiveHate;
@property (nonatomic, readonly) BOOL passedHiveSexual;
@property (nonatomic, readonly) BOOL passedHiveViolence;
@property (nonatomic, readonly) BOOL passedRegex;
@property (nonatomic, readonly) BOOL sexual;
@property (nonatomic, readonly) BOOL spam;
@property (nonatomic, readonly) BOOL violence;

@end

NS_ASSUME_NONNULL_END
