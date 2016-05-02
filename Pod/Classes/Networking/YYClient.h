//
//  YYClient.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Foundation/Foundation.h>
#import "YakKit-Constants.h"

@import CoreLocation;
@class YYConfiguration, YYUser, YYPeekLocation, YYYak, YYComment, YYNotification, YYVotable;


extern BOOL YYIsValidUserIdentifier(NSString * _Nonnull uid);


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject

+ (instancetype)sharedClient;

/// KVO compliant.
@property (nonatomic, readonly, nullable) YYConfiguration *configuration;
/// KVO compliant.
@property (nonatomic, readonly, nullable) YYUser *currentUser;
@property (nonatomic, nullable) CLLocation       *location;
@property (nonatomic, nullable) NSString         *userIdentifier;
@property (nonatomic, readonly) NSString         *baseURLForRegion;
@property (nonatomic          ) NSString         *region;

#pragma mark General
/// Updates the `configuration` object. Will post kYYDidUpdateConfigurationNotification on success before calling the completion block.
- (void)updateConfiguration:(nullable ErrorBlock)completion;
/// Updates the `currentUser` object. Will post kYYDidUpdateUserNotification on success before calling the completion block.
- (void)updateUser:(nullable ErrorBlock)completion;
/// Completion takes a the token as a string and the litefime of the code
- (void)authenticateForWeb:(void(^)(NSString *code, NSInteger timeout, NSError *error))completion;

#pragma mark Making requests
- (NSDictionary *)generalParams:(nullable NSDictionary *)additional;
- (void)postTo:(NSString *)endpoint callback:(nullable ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(nullable NSDictionary *)params sign:(BOOL)sign callback:(nullable ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(nullable NSDictionary *)params httpBodyParams:(nullable NSDictionary *)bodyParams sign:(BOOL)sign callback:(nullable ResponseBlock)callback;
- (void)get:(NSString *)endpoint callback:(nullable ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(nullable NSDictionary *)params sign:(BOOL)sign callback:(nullable ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(nullable NSDictionary *)params headers:(nullable NSDictionary *)headers sign:(BOOL)sign callback:(nullable ResponseBlock)callback;

- (NSString *)signRequest:(NSString *)endpoint params:(NSDictionary *)params;

#pragma mark Internal
- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;
- (void)handleStatus:(NSDictionary *)json callback:(nullable ErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END

#define URL(base, endpoint) [base stringByAppendingString:endpoint]
#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]