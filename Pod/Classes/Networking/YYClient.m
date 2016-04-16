//
//  YYClient.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYClient.h"
#import "NSString+YakKit.h"
#import "NSDictionary+YakKit.h"
#import <SystemConfiguration/SCNetworkReachability.h>

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
    _baseURLForRegion = [NSString stringWithFormat:@"https://%@.yikyakapi.net/api/", region];
}

#pragma mark General

- (void)updateConfiguration:(ErrorBlock)completion {
    NSURL *url = [NSURL URLWithString:[kBaseContent stringByAppendingString:kepUpdateConfiguration]];
    url = url;
}

#pragma mark Requests / error handling

static NSMutableArray *requestCache;

- (NSMutableURLRequest *)request:(NSURL *)url post:(BOOL)post body:(nullable NSDictionary *)params headers:(nullable NSDictionary *)headers {
    NSParameterAssert(url); NSAssert(self.cookie, @"Cannot make any requests without the cookie");
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
    
    if (!headers) {
        headers = @{@"Cookie": self.cookie, @"User-Agent": kUserAgent};
    } else {
        headers = [headers dictionaryByReplacingValuesForKeys:@{@"Cookie": self.cookie, @"User-Agent": kUserAgent}];
    }
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    request.URL = url;//[NSURL URLWithString:url];
    request.HTTPBody   = [[NSString queryStringWithParams:params] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = post ? @"POST" : @"GET";
    
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
    
    [message appendFormat:@"&salt=%@&hash=%@", salt, hash];
    return message; //[params dictionaryByReplacingValuesForKeys:@{@"salt": salt, @"hash": hash}];
}

+ (NSError *)unknownError {
    return [self errorWithMessage:@"Unknown error" code:1];
}

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"YakKit" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

- (void)handleError:(NSError *)error data:(NSData *)data response:(NSURLResponse *)response completion:(ResponseBlock)completion {
    NSParameterAssert(completion); NSParameterAssert(response);
    
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
                NSString *message = [NSString stringWithFormat:@"Unknown error:\n%@", text];
                completion(nil, [YYClient errorWithMessage:message code:1]);
            }
        }
        assert(json);
        if ((code > 199 && code < 300) || code == 304) {
            // Suceeded with a response
            completion(json, nil);
        } else {
            // Failed with a message
            error = [YYClient errorWithMessage:json[@"message"] code:code];
            completion(nil, error);
        }
    } else if ((code > 199 && code < 300) || code == 304) {
        // Succeeded with no response
        completion(nil, nil);
    } else {
        completion(nil, [YYClient unknownError]);
    }
}

- (NSDictionary *)generalParams {
    NSAssert(self.userIdentifier, @"Cannot make this request without a user identifier");
    NSAssert(self.location, @"Cannot make this request without a location");
    return @{@"userID": self.userIdentifier,
             @"lat": @(self.location.coordinate.latitude),
             @"long": @(self.location.coordinate.longitude),
             @"userLat": @(0),
             @"userLong": @(0),
             @"version": kYikYakVersion,
             @"horizontalAccuracy": @(0),
             @"verticalAccuracy": @(0),
             @"altitude": @(0),
             @"floorLevel": @(0),
             @"speed": @(0),
             @"course": @(0)};
}

/// Posts to the given endpoint with "general parameters"
- (void)postTo:(NSString *)endpoint callback:(ResponseBlock)callback {
    [self postTo:endpoint params:[self generalParams] callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params callback:(ResponseBlock)callback {
    [self postTo:endpoint params:params httpBodyParams:nil callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams callback:(ResponseBlock)callback {
    [self postTo:endpoint params:params httpBodyParams:bodyParams headers:nil callback:callback];
}

- (void)postTo:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint);
    
    NSURL *url = [NSURL URLWithString:[endpoint stringByAppendingString:[self signRequest:endpoint params:params]]];
    NSMutableURLRequest *request = [self request:url post:YES body:bodyParams headers:headers];
    [self request:request callback:callback];
}

- (void)get:(NSString *)endpoint params:(NSDictionary *)params httpBodyParams:(NSDictionary *)bodyParams headers:(NSDictionary *)headers callback:(ResponseBlock)callback {
    NSParameterAssert(endpoint);
    
    NSURL *url = [NSURL URLWithString:[endpoint stringByAppendingString:[self signRequest:endpoint params:params]]];
    NSMutableURLRequest *request = [self request:url post:NO body:bodyParams headers:headers];
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
