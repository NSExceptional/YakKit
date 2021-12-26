//
//  YYClient.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Foundation/Foundation.h>
#import "YakKit-Constants.h"
#import <TBURLRequestOptions/TBURLRequestBuilder.h>

@import CoreLocation;
@class YYConfiguration, YYUser, YYPeekLocation;
@class YYYak, YYComment, YYNotification, YYVotable;
@class FIRUser;


BOOL YYIsValidPhoneNumber(NSString *phone);
NSString * _Nullable YYExtractFormattedPhoneNumber(NSString *phone);
extern NSString * _Nonnull YYUniqueIdentifier();


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject <NSCopying>

@property (nonatomic, readonly, class) YYClient *sharedClient;

/// KVO compliant.
@property (nonatomic, readonly, nullable) YYConfiguration *configuration;
/// KVO compliant.
@property (nonatomic, readonly, nullable) YYUser *currentUser;
@property (nonatomic, nullable) CLLocation       *location;
@property (nonatomic, nullable) NSString         *userIdentifier;
@property (nonatomic, readonly) NSString         *baseURLForRegion;
@property (nonatomic          ) NSString         *region;

#pragma mark General
- (void)startSignInWithPhone:(NSString *)phoneNumber verify:(YYStringBlock)verificationCallback;
- (void)verifyPhone:(NSString *)code identifier:(NSString *)verificationID completion:(YYErrorBlock)completion;
/// Updates the `configuration` object. Will post kYYDidUpdateConfigurationNotification on success before calling the completion block.
- (void)updateConfiguration:(nullable YYErrorBlock)completion;
/// Updates the `currentUser` object. Will post kYYDidUpdateUserNotification on success before calling the completion block.
- (void)updateUser:(nullable YYErrorBlock)completion;
/// Completion takes a the token as a string and the litefime of the code
- (void)authenticateForWeb:(void(^)(NSString *code, NSInteger timeout, NSError *error))completion;

#pragma mark Making requests
@property (nonatomic, readonly) NSDictionary *generalHeaders;

- (NSDictionary *)generalQuery:(nullable NSDictionary *)additional;

- (void)post:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)get:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedPost:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;
- (void)unsignedGet:(void(^)(TBURLRequestBuilder *make))configurationHandler callback:(TBResponseBlock)callback;

#pragma mark Internal
- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(YYArrayBlock)completion;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;
- (void)handleStatus:(NSDictionary *)json callback:(nullable YYErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END

#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]
