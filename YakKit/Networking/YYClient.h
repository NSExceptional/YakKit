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
@class FIRUser;


BOOL YYIsValidPhoneNumber(NSString * _Nonnull phone);
NSString * _Nullable YYExtractFormattedPhoneNumber(NSString * _Nonnull phone);
extern NSString * _Nonnull YYUniqueIdentifier();


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject

@property (nonatomic, readonly, class) YYClient *sharedClient;

/// KVO compliant.
@property (nonatomic, readonly, nullable) YYUser *currentUser;
@property (nonatomic, nullable) CLLocation       *location;
@property (nonatomic, nullable) NSString         *userIdentifier;

@property (nonatomic) NSString *authToken;
@property (nonatomic) NSString *refreshToken;

#pragma mark General
- (void)startSignInWithPhone:(NSString *)phoneNumber verify:(YYStringBlock)verificationCallback;
- (void)verifyPhone:(NSString *)code identifier:(NSString *)verificationID completion:(YYErrorBlock)completion;
/// Updates the `currentUser` object. Will post kYYDidUpdateUserNotification on success before calling the completion block.
- (void)updateUser:(nullable YYErrorBlock)completion;

#pragma mark Making requests
@property (nonatomic, readonly) NSDictionary *graphQLHeaders;

- (NSDictionary *)generalQuery:(nullable NSDictionary *)additional;

- (void)post:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)get:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedPost:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedGet:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;

- (void)graphQL:(NSString *)query variables:(NSDictionary<NSString *, id> *)variables callback:(TBResponseBlock)callback;

#pragma mark Internal
- (void)completeWithClass:(Class)cls object:(NSString *)keyPath response:(TBResponseParser *)parser completion:(YYArrayBlock)completion;
- (void)completeWithClass:(Class)cls array:(NSString *)keyPath response:(TBResponseParser *)parser completion:(YYArrayBlock)completion;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;
- (void)handleStatus:(NSDictionary *)json callback:(nullable YYErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END

#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]
