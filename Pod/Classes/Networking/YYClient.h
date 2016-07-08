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
@class LYRClient;
@class YYConfiguration, YYUser, YYPeekLocation;
@class YYYak, YYComment, YYNotification, YYVotable;


extern BOOL YYIsValidUserIdentifier(NSString * _Nonnull uid);
extern NSString * _Nonnull YYUniqueIdentifier();


NS_ASSUME_NONNULL_BEGIN

@interface YYClient : NSObject <NSCopying>

+ (instancetype)sharedClient;

/// KVO compliant.
@property (nonatomic, readonly, nullable) YYConfiguration *configuration;
/// KVO compliant.
@property (nonatomic, readonly, nullable) YYUser *currentUser;
@property (nonatomic, nullable) CLLocation       *location;
@property (nonatomic, nullable) NSString         *userIdentifier;
@property (nonatomic, readonly) NSString         *baseURLForRegion;
@property (nonatomic          ) NSString         *region;
/// Set this property manually if you want to use chat. Requires the LayerKit framework.
@property (nonatomic, nullable) LYRClient        *layerClient;

#pragma mark General
/// Updates the `configuration` object. Will post kYYDidUpdateConfigurationNotification on success before calling the completion block.
- (void)updateConfiguration:(nullable ErrorBlock)completion;
/// Updates the `currentUser` object. Will post kYYDidUpdateUserNotification on success before calling the completion block.
- (void)updateUser:(nullable ErrorBlock)completion;
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
- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;
- (void)handleStatus:(NSDictionary *)json callback:(nullable ErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END

#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]