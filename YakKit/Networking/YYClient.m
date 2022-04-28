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
#import <SystemConfiguration/SCNetworkReachability.h>
#import <Firebase.h>
@import TBURLRequestOptions;

#define Host(string) [string matchGroupAtIndex:1 forRegex:kHostRegexPattern]
// Relies on the fact that kHostRegexPattern does not end in a '/'
#define Endpoint(string) [string stringByReplacingCharactersInRange:NSMakeRange( \
    0, [string tb_matchGroupAtIndex:0 forRegex:kHostRegexPattern].length \
) withString:@""]


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

BOOL YYIsValidPhoneNumber(NSString *phone) {
    NSDataDetector *pattern = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    return [pattern numberOfMatchesInString:phone options:0 range:NSMakeRange(0, phone.length)];
}

NSString * YYExtractFormattedPhoneNumber(NSString *input) {
    static NSDataDetector *pattern = nil;
    static NSCharacterSet *notDigits = nil;
    if (!pattern || !notDigits) {
        pattern = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
        notDigits = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"].invertedSet;
    }
    
    NSTextCheckingResult *match = [pattern firstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
    return [[match.phoneNumber componentsSeparatedByCharactersInSet:notDigits] componentsJoinedByString:@""];
}

NSString * YYUniqueIdentifier() {
    NSString *uuid = [NSUUID new].UUIDString.tb_MD5Hash;
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

- (void)setCurrentUser:(YYUser *)currentUser {
    _currentUser = currentUser;
}

#pragma mark General

- (void)startSignInWithPhone:(NSString *)phoneNumber verify:(YYStringBlock)verificationCallback {
    if (![phoneNumber hasPrefix:@"+1"]) {
        phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
    }
    
    [FIRPhoneAuthProvider.provider verifyPhoneNumber:phoneNumber UIDelegate:nil completion:verificationCallback];
}

- (void)verifyPhone:(NSString *)code identifier:(NSString *)verificationID completion:(YYErrorBlock)completion {
    FIRPhoneAuthCredential *cred = [FIRPhoneAuthProvider.provider
        credentialWithVerificationID:verificationID
        verificationCode:code
    ];
    [FIRAuth.auth signInWithCredential:cred completion:^(FIRAuthDataResult *authResult, NSError *error) {
        _currentUser = (id)authResult.user;
        self.refreshToken = authResult.user.refreshToken;
        
        [authResult.user getIDTokenWithCompletion:^(NSString *token, NSError *error) {
            if (token) {
                self.authToken = token;
            }
            completion(error);
        }];
    }];
}

- (void)updateUser:(nullable YYErrorBlock)completion {
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

#pragma mark Helper methods

- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(YYArrayBlock)completion {
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
//                              @"version": kYikYakVersion,
                              @"horizontalAccuracy": @"0.000000",
                              @"verticalAccuracy": @"0.000000",
                              @"altitude": @"0.000000",
                              @"floorLevel": @"0",
                              @"speed": @"0.000000",
                              @"course": @"0.000000"};
    
    if (additional.count) {
        general = [general tb_dictionaryByReplacingValuesForKeys:additional];
    }
    
    return general;
}

- (NSDictionary *)graphQLHeaders {
    return @{
        @"Authorization": self.authToken
    };
}

#pragma mark Requests / error handling

- (NSURL *)URLFromFullURL:(NSString *)urlString sign:(BOOL)sign {
    if (sign) {
        NSString *endpointWithQuery = Endpoint(urlString);
        NSRange r = NSMakeRange(urlString.length - endpointWithQuery.length, endpointWithQuery.length);
        urlString = [urlString stringByReplacingCharactersInRange:r withString:Endpoint(urlString)];
        return [NSURL URLWithString:urlString];
    } else {
        return [NSURL URLWithString:urlString];
    }
}

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [TBResponseParser error:message domain:@"YakKit" code:code];
}

- (void)handleStatus:(NSDictionary *)json callback:(nullable YYErrorBlock)completion {
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

- (void)graphQL:(NSString *)query variables:(NSDictionary<NSString *,id> *)variables callback:(TBResponseBlock)callback {
    [self unsignedPost:^(TBURLRequestBuilder * _Nonnull make) {
        make.baseURL(kBaseAPIURL).headers(self.graphQLHeaders);
        make.bodyJSON(@{ @"query": query, @"variables": variables });
    } callback:callback];
}

@end
