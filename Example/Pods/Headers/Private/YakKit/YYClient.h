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
@class YYSession, YYPeekLocation, YYYak, YYComment, YYNotification, YYVotable;


NS_ASSUME_NONNULL_END
@interface YYClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic) YYSession  *currentSession;
@property (nonatomic) CLLocation *location;

@property (nonatomic) NSString   *cookie;
@property (nonatomic) NSString   *userIdentifier;

#pragma mark Requests
- (NSDictionary *)generalParams;
- (void)postTo:(NSString *)endpoint callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(nullable NSDictionary *)params callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams callback:(ResponseBlock)callback;
- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback;
- (void)get:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback;

@end

