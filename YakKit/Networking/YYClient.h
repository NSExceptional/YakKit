//
//  YYClient.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Foundation/Foundation.h>
#import "YakKit-Constants.h"
@import TBURLRequestOptions;

@import CoreLocation;
@class YYUser, YYPeekLocation;
@class YYYak, YYComment, YYNotification, YYVotable;
@class FIRFirestore, FIRUser;


BOOL YYIsValidPhoneNumber(NSString * _Nonnull phone);
NSString * _Nullable YYExtractFormattedPhoneNumber(NSString * _Nonnull phone);
extern NSString * _Nonnull YYUniqueIdentifier();


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject

@property (nonatomic, readonly, nullable) YYUser   *currentUser;
@property (nonatomic, readonly, nullable) FIRUser  *currentFirebaseUser;
@property (nonatomic, readonly, nullable) NSString *userIdentifier;
@property (nonatomic, nullable) CLLocation         *location;

@property (nonatomic, nullable) NSString *authToken;
@property (nonatomic, nullable) NSString *refreshToken;
@property (nonatomic, nullable) NSDate *authTokenExpiry;
@property (nonatomic, readonly) FIRFirestore *firestore;

@property (nonatomic, readonly, nullable) NSError *notLoggedIn;
@property (nonatomic, readonly) NSError *nullResponse;

/// Whether the Yik Yak servers are online and reachable
@property (nonatomic, readonly) BOOL reachable;

#pragma mark General
- (void)startSignInWithPhone:(NSString *)phoneNumber verify:(YYStringBlock)verificationCallback;
- (void)verifyPhone:(NSString *)code identifier:(NSString *)verificationID completion:(YYErrorBlock)completion;
/// Use this to reauthenticate when the auth token expires
- (void)refreshAuthToken:(BOOL)forceRefresh completion:(YYErrorBlock)completion;
/// Loads the current user from Firebase and gets its auth token, populating \c currentFirebaseUser and \c authToken
- (void)loadCurrentUser:(YYErrorBlock)completion;
/// Updates the `currentUser` object. Will post kYYDidUpdateUserNotification on success before calling the completion block.
- (void)updateUser:(nullable YYErrorBlock)completion;

- (void)guardLoggedIn:(void(^)())loggedInBlock loggedOut:(nullable void(^)())loggedOutBlock;

#pragma mark Making requests
@property (nonatomic, readonly) NSDictionary *graphQLHeaders;
@property (nonatomic, readonly) NSString *graphQLLocation;

- (NSDictionary *)generalQuery:(nullable NSDictionary *)additional;

- (void)post:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)get:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedPost:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedGet:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;

- (void)graphQL:(NSString *)query variables:(NSDictionary<NSString *, id> *)variables callback:(TBResponseBlock)callback;

#pragma mark Firebase

- (void)setData:(NSDictionary *)data onDocument:(NSArray<NSString *> *)pathComponents completion:(YYErrorBlock)handler;
- (void)deleteDocumentData:(NSArray<NSString *> *)pathComponents completion:(YYErrorBlock)handler;

#pragma mark Internal
- (void)completeWithResponse:(TBResponseParser *)parser completion:(nullable YYErrorBlock)handler;

- (void)completeWithClass:(Class)cls
                   object:(NSString *)keyPath
                 response:(TBResponseParser *)parser
               completion:(YYResponseBlock)completion;

- (void)completeWithClass:(Class)cls
                    array:(NSString *)keyPath
                 response:(TBResponseParser *)parser
               completion:(YYArrayBlock)completion;

- (void)completeWithPaginatedClass:(Class)cls
                          dataPath:(NSString *)keyPath
                          response:(TBResponseParser *)parser
                        completion:(YYArrayPageBlock)completion;

- (nullable NSError *)tryDecodeAPIError:(TBResponseParser *)parser contextualPath:(nullable NSString *)keyPath;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END

#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]
