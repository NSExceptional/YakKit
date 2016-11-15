//
//  YYClient.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYClient.h"
#import "YYThing.h"
#import "YYUser.h"
#import "YYConfiguration.h"
#import "NSString+Networking.h"
#import "NSDictionary+Networking.h"
#import <SystemConfiguration/SCNetworkReachability.h>

#define Host(string) [string matchGroupAtIndex:1 forRegex:kHostRegexPattern]
// Relies on the fact that kHostRegexPattern does not end in a '/'
#define Endpoint(string) [string stringByReplacingCharactersInRange:NSMakeRange(0, [string matchGroupAtIndex:0 forRegex:kHostRegexPattern].length) withString:@""]


BOOL YYHasActiveConnection() {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "content.yikyakapi.net" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

BOOL YYIsValidUserIdentifier(NSString *uid) {
    return [uid matchGroupAtIndex:0 forRegex:@"^[a-zA-Z\\d]{8}-[a-zA-Z\\d]{4}-[a-zA-Z\\d]{4}-[a-zA-Z\\d]{4}-[a-zA-Z\\d]{12}$"] != nil;
}

NSString * YYUniqueIdentifier() {
    NSString *uuid = [NSUUID new].UUIDString.MD5Hash;
    return [NSString stringWithFormat:@"%8@-%4@-%4@-%4@-%12@",
            [uuid substringWithRange:NSMakeRange(0, 8)],
            [uuid substringWithRange:NSMakeRange(8, 4)],
            [uuid substringWithRange:NSMakeRange(12, 4)],
            [uuid substringWithRange:NSMakeRange(16, 4)],
            [uuid substringWithRange:NSMakeRange(20, 12)]];
}


@implementation YYClient

+ (instancetype)sharedClient {
    static YYClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    
    return sharedClient;
}

- (id)init {
    self = [super init];
    if (self) {
        self.region = @"us-central-api";
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YYClient *new      = [YYClient new];
    new.currentUser    = self.currentUser;
    new.location       = self.location;
    new.userIdentifier = self.userIdentifier;
    new.region         = self.region;
    new.layerClient    = self.layerClient;
    return new;
}

- (void)setRegion:(NSString *)region {
    NSParameterAssert(region);
    _region = region;
    _baseURLForRegion = [NSString stringWithFormat:@"https://%@.yikyakapi.net", region];
}

- (void)setCurrentUser:(YYUser *)currentUser {
    _currentUser = currentUser;
}

- (void)setConfiguration:(YYConfiguration *)configuration {
    _configuration = configuration;
}

#pragma mark General

- (void)updateConfiguration:(nullable ErrorBlock)completion {
    NSDictionary *params = @{@"lat": @(self.location.coordinate.longitude),
                             @"lng": @(self.location.coordinate.latitude),
                             @"yakkerID": self.userIdentifier};
    [self unsignedGet:^(TBURLRequestBuilder * _Nonnull make) {
        make.baseURL(kBaseContentURL).endpoint(kepUpdateConfiguration).queries(params);
    } callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            self.configuration = [[YYConfiguration alloc] initWithDictionary:parser.JSON];
            [[NSNotificationCenter defaultCenter] postNotificationName:kYYDidUpdateConfigurationNotification object:self];
            YYRunBlockP(completion, nil);
        } else {
            YYRunBlockP(completion, parser.error);
        }
    }];
}

- (void)updateUser:(nullable ErrorBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:kepGetUserData_user, self.userIdentifier];
    [self get:^(TBURLRequestBuilder * _Nonnull make) {
        make.endpoint(endpoint);
    } callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            self.currentUser = [[YYUser alloc] initWithDictionary:parser.JSON[@"user"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kYYDidUpdateUserNotification object:self];
            YYRunBlockP(completion, nil);
        } else {
            YYRunBlockP(completion, parser.error);
        }
    }];
}

- (void)authenticateForWeb:(void(^)(NSString *code, NSInteger timeout, NSError *error))completion {
    [self post:^(TBURLRequestBuilder * _Nonnull make) {
        make.baseURL(nil).URL(kAuthForWebURL);
    } callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            completion(parser.JSON[@"pin"], [parser.JSON[@"ttl"] integerValue], nil);
        } else {
            completion(nil, 0, parser.error);
        }
    }];
}

#pragma mark Helper methods

- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion {
    completion(error ? nil : [[cls class] arrayOfModelsFromJSONArray:objects], error);
}

- (NSDictionary *)generalQuery:(NSDictionary *)additional {
    NSAssert(self.userIdentifier, @"Cannot make this request without a user identifier");
    NSAssert(self.location, @"Cannot make this request without a location");
    
    NSDictionary *general = @{@"userID": self.userIdentifier,
                              @"lat": @(self.location.coordinate.latitude).stringValue,
                              @"long": @(self.location.coordinate.longitude).stringValue,
                              @"userLat":  @(self.location.coordinate.latitude).stringValue,
                              @"userLong": @(self.location.coordinate.longitude).stringValue,
                              @"version": kYikYakVersion,
                              @"horizontalAccuracy": @"0.000000",
                              @"verticalAccuracy": @"0.000000",
                              @"altitude": @"0.000000",
                              @"floorLevel": @"0",
                              @"speed": @"0.000000",
                              @"course": @"0.000000"};
    
    if (additional.count) {
        general = [general dictionaryByReplacingValuesForKeys:additional];
    }
    
    return general;
}

- (NSDictionary *)generalHeaders {
    return @{@"User-Agent": kUserAgent,};
    //             @"X-ThePantsThief-Header": @"1"};
}

#pragma mark Requests / error handling

- (NSURL *)URLFromFullURL:(NSString *)urlString sign:(BOOL)sign {
    if (sign) {
        NSString *endpointWithQuery = Endpoint(urlString);
        NSRange r = NSMakeRange(urlString.length - endpointWithQuery.length, endpointWithQuery.length);
        urlString = [urlString stringByReplacingCharactersInRange:r withString:[self signRequest:Endpoint(urlString)]];
        return [NSURL URLWithString:urlString];
    } else {
        return [NSURL URLWithString:urlString];
    }
}

- (NSString *)signRequest:(NSString *)endpointWithQuery {
    NSString *salt = [[NSString timestamp] substringToIndex:10];
    
    NSMutableString *message = endpointWithQuery.mutableCopy;
    
    // Hash that bitch
    NSString *input = [message stringByAppendingString:salt];
    NSString *hash = [[NSString hashHMacSHA1:input key:kRequestSignKey] base64EncodedStringWithOptions:0];
    [message appendFormat:@"&salt=%@&hash=%@", salt, hash.URLEncodedString];
    return message;
}

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [TBResponseParser error:message domain:@"YakKit" code:code];
}

- (void)handleStatus:(NSDictionary *)json callback:(nullable ErrorBlock)completion {
    if ([json[@"status"] isEqualToString:@"ok"]) {
        YYRunBlockP(completion, nil);
    } else {
        YYRunBlockP(completion, [YYClient errorWithMessage:json[@"error"] code:1]);
    }
}

#pragma mark POST and GET

- (TBResponseBlock)makeAlwaysTryParseJSON:(TBResponseBlock)callback {
    return ^(TBResponseParser *parser) {
        parser.ignoreContentTypeForJSON = YES;
        callback(parser);
    };
}

- (TBURLRequestProxy *)request:(void(^)(TBURLRequestBuilder *))configurationHandler sign:(BOOL)sign {
    NSParameterAssert(self.userIdentifier);
    
    TBURLRequestProxy *proxy = [TBURLRequestBuilder make:^(TBURLRequestBuilder *make) {
        make.baseURL(self.baseURLForRegion).headers(self.generalHeaders).queries([self generalQuery:nil]);
        configurationHandler(make);
    }];
    
    if (sign) {
        proxy.request.URL = [self URLFromFullURL:proxy.request.URL.absoluteString sign:sign];
    }
    
    return proxy;
}

- (void)post:(void(^)(TBURLRequestBuilder *))configurationHandler callback:(TBResponseBlock)callback {
    callback = [self makeAlwaysTryParseJSON:callback];
    [[self request:configurationHandler sign:YES] POST:callback];
}

- (void)get:(void(^)(TBURLRequestBuilder *))configurationHandler callback:(TBResponseBlock)callback {
    callback = [self makeAlwaysTryParseJSON:callback];
    [[self request:configurationHandler sign:YES] GET:callback];
}

- (void)unsignedPost:(void(^)(TBURLRequestBuilder *))configurationHandler callback:(TBResponseBlock)callback {
    callback = [self makeAlwaysTryParseJSON:callback];
    [[self request:configurationHandler sign:NO] POST:callback];
}

- (void)unsignedGet:(void(^)(TBURLRequestBuilder *))configurationHandler callback:(TBResponseBlock)callback {
    callback = [self makeAlwaysTryParseJSON:callback];
    [[self request:configurationHandler sign:NO] GET:callback];
}

@end
