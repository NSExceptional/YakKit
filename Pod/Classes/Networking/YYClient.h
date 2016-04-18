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
@class YYConfiguration, YYPeekLocation, YYYak, YYComment, YYNotification, YYVotable;


@interface YYClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic, readonly) YYConfiguration *configuration;
@property (nonatomic, readonly) NSString *baseURLForRegion;
@property (nonatomic) NSString   *region;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSString   *userIdentifier;

#pragma mark General
- (void)updateConfiguration:(ErrorBlock)completion;

#pragma mark Making requests
- (NSDictionary *)generalParams:(NSDictionary *)additional;
- (void)postTo:(NSString *)endpoint callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params sign:(BOOL)sign callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams sign:(BOOL)sign callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers sign:(BOOL)sign callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(NSDictionary *)params sign:(BOOL)sign callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(NSDictionary *)params headers:(NSDictionary *)headers sign:(BOOL)sign callback:(ResponseBlock)callback;

- (NSString *)signRequest:(NSString *)endpoint params:(NSDictionary *)params;

#pragma mark Internal
- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion;
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;
- (void)handleStatus:(NSDictionary *)json callback:(nullable ErrorBlock)completion;

@end

#define URL(base, endpoint) [base stringByAppendingString:endpoint]
#define URLDynamic(base, endpoint, ...) [NSString stringWithFormat:URL(base, endpoint), __VA_ARGS__]