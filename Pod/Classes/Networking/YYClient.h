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

@property (nonatomic) NSString   *cookie;
@property (nonatomic) NSString   *userIdentifier;

#pragma mark General
- (void)updateConfiguration:(ErrorBlock)completion;

#pragma mark Making requests
- (NSDictionary *)generalParams;
- (void)postTo:(NSString *)endpoint callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback;

@end

