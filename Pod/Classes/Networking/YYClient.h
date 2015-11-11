//
//  YYClient.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@class YYSession, YYPeekLocation, YYYak, YYComment, YYNotification, YYVotable;


typedef void (^RequestBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BooleanBlock)(BOOL success, NSError *error);
typedef void (^DataBlock)(NSData *data, NSError *error);
typedef void (^StringBlock)(NSString *string, NSError *error);
typedef void (^DictionaryBlock)(NSDictionary *dict, NSError *error);
typedef void (^ArrayBlock)(NSArray *collection, NSError *error);
typedef void (^CollectionResponseBlock)(NSArray *success, NSArray *failed, NSArray *errors);
typedef void (^ResponseBlock)(id object, NSError *error);
typedef void (^MiddleManBlock)(id object, NSError *error, NSURLResponse *response);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^VoidBlock)();


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic) YYSession  *currentSession;
@property (nonatomic) CLLocation *location;

@property (nonatomic) NSString   *cookie;
@property (nonatomic) NSString   *userIdentifier;

#pragma mark Getting yak feeds
- (void)updateSession:(ErrorBlock)completion;
- (void)updateSession:(BOOL)getYaks completion:(ArrayBlock)completion;
- (void)getLocalHotYaks:(ArrayBlock)completion;
- (void)getLocalTopYaks:(ArrayBlock)completion;
- (void)getYaksInPeek:(YYPeekLocation *)location completion:(ArrayBlock)completion;

#pragma mark Getting comments
- (void)getCommentsForYak:(YYYak *)yak completion:(ArrayBlock)completion;

#pragma mark Getting user data
- (void)getNotifications:(ArrayBlock)completion;
- (void)getMyRecentYaks:(ArrayBlock)completion;
- (void)getMyTopYaks:(ArrayBlock)completion;
- (void)getMyRecentReplies:(ArrayBlock)completion;

#pragma mark Posting / removing yaks
- (void)postYak:(NSString *)title handle:(nullable NSString *)handle completion:(ErrorBlock)completion;
- (void)deleteYak:(YYYak *)yak completion:(ErrorBlock)completion;

#pragma mark Posting / removing comments
- (void)postComment:(NSString *)body toYak:(YYYak *)yak completion:(ErrorBlock)completion;
- (void)deleteComment:(YYComment *)comment completion:(ErrorBlock)completion;

#pragma mark Voting
- (void)upvote:(YYVotable *)yakOrComment completion:(ErrorBlock)completion;
- (void)downvote:(YYVotable *)yakOrComment completion:(ErrorBlock)completion;
- (void)removeVote:(YYVotable *)yakOrComment completion:(ErrorBlock)completion;

#pragma mark Misc
- (void)logEvent:(NSDictionary *)params completion:(ErrorBlock)completion;
- (void)refreshLocate:(ErrorBlock)completion;
- (void)mark:(NSArray<YYNotification *> *)notifications read:(BOOL)read completion:(DictionaryBlock)completion;

@end

NS_ASSUME_NONNULL_END
