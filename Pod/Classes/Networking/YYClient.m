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
#import "NSString+YakKit.h"
#import "NSDictionary+YakKit.h"
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
        self.region = @"us-east-api";
    }
    
    return self;
}

- (void)setRegion:(NSString *)region {
    NSParameterAssert(region);
    _region = region;
    _baseURLForRegion = [NSString stringWithFormat:@"https://%@.yikyakapi.net", region];
}

#pragma mark General

- (void)updateConfiguration:(ErrorBlock)completion {
    NSDictionary *params = @{@"lat": @(self.location.coordinate.longitude),
                             @"lng": @(self.location.coordinate.latitude),
                             @"yakkerID": self.userIdentifier};
    [self get:URL(kBaseContentURL, kepUpdateConfiguration) params:params sign:NO callback:^(NSDictionary *json, NSError *error) {
        _configuration = [[YYConfiguration alloc] initWithDictionary:json];
        completion(error);
    }];
}

- (void)updateUser:(ErrorBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:kepGetUserData_user, self.userIdentifier];
    [self get:URL(self.baseURLForRegion, endpoint) callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            _currentUser = [[YYUser alloc] initWithDictionary:json];
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (void)authenticateForWeb:(void(^)(NSString *code, NSInteger timeout, NSError *error))completion {
    [self postTo:kAuthForWebURL callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion(json[@"pin"], [json[@"ttl"] integerValue], nil);
        } else {
            completion(nil, 0, error);
        }
    }];
}

#pragma mark Helper methods

- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion {
    if (!error) {
        completion([[cls class] arrayOfModelsFromJSONArray:objects], nil);
    } else {
        completion(nil, error);
    }
}

- (NSURL *)URLFromFullURL:(NSString *)urlString params:(NSDictionary *)params sign:(BOOL)sign {
    if (sign) {
        NSString *endpoint = Endpoint(urlString);
        NSRange r = NSMakeRange(urlString.length - endpoint.length, endpoint.length);
        urlString = [urlString stringByReplacingCharactersInRange:r withString:[self signRequest:Endpoint(urlString) params:params]];
        return [NSURL URLWithString:urlString];
    } else {
        return [NSURL URLWithString:urlString];
    }
}

- (NSDictionary *)generalParams:(NSDictionary *)additional {
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

- (NSDictionary *)generalHeaders:(NSString *)endpoint {
    return @{@"Host": Host(endpoint),
             @"User-Agent": kUserAgent,
             @"X-ThePantsThief-Header": @"1"};
}

#pragma mark Requests / error handling

static NSMutableArray *requestCache;

- (NSMutableURLRequest *)request:(NSURL *)url post:(BOOL)post body:(nullable NSDictionary *)params headers:(nullable NSDictionary *)headers {
    NSParameterAssert(url);
    // Init request cache
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestCache = [NSMutableArray array];
    });
    
    // Get NSMutableURLRequest instance
    NSMutableURLRequest *request;
    if (requestCache.count) {
        request = requestCache.lastObject;
        [requestCache removeLastObject];
    } else {
        request = [[NSMutableURLRequest alloc] initWithURL:url];//[NSURL URLWithString:url]];
    }
    
    request.URL = url;//[NSURL URLWithString:url];
    request.HTTPBody   = [[NSString queryStringWithParams:params] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = post ? @"POST" : @"GET";
    request.allHTTPHeaderFields = headers;
    
    return request;
}

- (void)returnRequest:(NSMutableURLRequest *)request {
    [requestCache addObject:request];
}

- (NSString *)signRequest:(NSString *)endpoint params:(NSDictionary *)params {
    NSMutableString *message = [NSMutableString stringWithString:endpoint];
    NSString *salt = [NSString timestamp];
    //    NSArray *keys = [params.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    // Append parameters and salt to message before hashing
    if (params.count) {
        [message appendFormat:@"?%@", [NSString queryStringWithParams:params]];
    }
    
    // Hash that bitch
    NSString *hash = [[NSString hashHMacSHA1:[message stringByAppendingString:salt] key:kRequestSignKey] base64EncodedStringWithOptions:0];
    [message appendFormat:@"&salt=%@&hash=%@", salt, hash.URLEncodedString];
    return message;
}

+ (NSError *)unknownError {
    return [self errorWithMessage:@"Unknown error" code:1];
}

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"YakKit" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion {
    NSParameterAssert(completion); NSParameterAssert(response); NSParameterAssert(data);
    
    NSInteger code = [(NSHTTPURLResponse *)response statusCode];
    
    if (error) {
        completion(nil, error);
    }
    else if (data.length) {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        // Could not parse JSON (it's probably raw text)
        if (jsonError) {
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([text hasPrefix:@"http"]) {
                completion(text, nil);
            } else {
                text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                NSString *message = [NSString stringWithFormat:@"Unknown error:\n%@", text];
                completion(nil, [YYClient errorWithMessage:message code:1]);
            }
        } else {
            if ((code > 199 && code < 300) || code == 304) {
                // Suceeded with a response
                completion(json, nil);
            } else {
                // Failed with a message
                error = [YYClient errorWithMessage:json[@"message"] code:code];
                completion(nil, error);
            }
        }
    } else if ((code > 199 && code < 300) || code == 304) {
        // Succeeded with no response
        completion(nil, nil);
    } else {
        completion(nil, [YYClient unknownError]);
    }
}

- (void)handleStatus:(NSDictionary *)json callback:(nullable ErrorBlock)completion {
    if ([json[@"status"] isEqualToString:@"ok"]) {
        YYRunBlockP(completion, nil);
    } else {
        YYRunBlockP(completion, [YYClient errorWithMessage:json[@"error"] code:1]);
    }
}

#pragma mark POST and GET

/// Posts to the given endpoint with "general parameters"
- (void)postTo:(NSString *)endpoint callback:(ResponseBlock)callback {
    [self postTo:endpoint params:[self generalParams:nil] sign:YES callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params sign:(BOOL)sign callback:(ResponseBlock)callback {
    [self postTo:endpoint params:params httpBodyParams:@{} sign:sign callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams sign:(BOOL)sign callback:(ResponseBlock)callback {
    [self postTo:endpoint params:params httpBodyParams:bodyParams headers:[self generalHeaders:endpoint] sign:sign callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers sign:(BOOL)sign callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint);
    
    NSURL *url = [self URLFromFullURL:endpoint params:params sign:sign];
    NSMutableURLRequest *request = [self request:url post:YES body:bodyParams headers:headers];
    [self request:request callback:callback];
}

- (void)get:(NSString *)endpoint callback:(ResponseBlock)callback {
    [self get:endpoint params:[self generalParams:nil] sign:YES callback:callback];
}

- (void)get:(NSString *)endpoint params:(NSDictionary *)params sign:(BOOL)sign callback:(ResponseBlock)callback {
    [self get:endpoint params:params headers:[self generalHeaders:endpoint] sign:sign callback:callback];
}

- (void)get:(NSString *)endpoint params:(NSDictionary *)params headers:(NSDictionary *)headers sign:(BOOL)sign callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint);
    
    NSURL *url = [self URLFromFullURL:endpoint params:params ?: @{} sign:sign];
    NSMutableURLRequest *request = [self request:url post:NO body:@{} headers:headers];
    [self request:request callback:callback];
}

- (void)request:(NSMutableURLRequest *)request callback:(ResponseBlock)callback {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self returnRequest:request];
            [self handleError:error data:data response:response completion:callback];
        });
    }] resume];
}

@end