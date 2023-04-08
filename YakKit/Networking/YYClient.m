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
@import FirebaseAuth;
@import FirebaseCore;
@import FirebaseFirestore;
@import TBURLRequestOptions;

#define Host(string) [string matchGroupAtIndex:1 forRegex:kHostRegexPattern]
// Relies on the fact that kHostRegexPattern does not end in a '/'
#define Endpoint(string) [string stringByReplacingCharactersInRange:NSMakeRange( \
    0, [string tb_matchGroupAtIndex:0 forRegex:kHostRegexPattern].length \
) withString:@""]

#define isNull(thing) (!thing || thing == NSNull.null)


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
    return nil;
//    static YYClient *sharedClient = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedClient = [self new];
//    });
//    
//    return sharedClient;
}

- (NSString *)userIdentifier {
    return self.currentUser.identifier;
}

- (NSError *)notLoggedIn {
    static NSError *notLoggedInError = nil;
    if (!notLoggedInError) {
        notLoggedInError = [NSError errorWithDomain:@"yakkit" code:1 userInfo:@{
            NSLocalizedDescriptionKey: @"Not Logged In"
        }];
    }
    
    if (self.authToken) {
        return nil;
    }
    
    return notLoggedInError;
}

- (NSError *)nullResponse {
    static NSError *nullResponseError = nil;
    if (!nullResponseError) {
        nullResponseError = [NSError errorWithDomain:@"yikyak.com" code:1 userInfo:@{
            NSLocalizedDescriptionKey: @"API returned null object in response"
        }];
    }
    
    return nullResponseError;
}

- (FIRFirestore *)firestore {
    static FIRFirestore *store = nil;
    if (!store) {
        store = FIRFirestore.firestore;
    }
    
    return store;
}

- (BOOL)reachable {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "yikyak.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

#pragma mark General

- (void)startSignInWithPhone:(NSString *)phoneNumber verify:(YYStringBlock)verificationCallback {
    NSParameterAssert(verificationCallback);
    
    if (![phoneNumber hasPrefix:@"+1"]) {
        phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
    }
    
    [FIRPhoneAuthProvider.provider verifyPhoneNumber:phoneNumber UIDelegate:nil completion:verificationCallback];
}

- (void)verifyPhone:(NSString *)code identifier:(NSString *)verificationID completion:(YYErrorBlock)completion {
    NSParameterAssert(completion);
    
    FIRPhoneAuthCredential *cred = [FIRPhoneAuthProvider.provider
        credentialWithVerificationID:verificationID
        verificationCode:code
    ];
    [FIRAuth.auth signInWithCredential:cred completion:^(FIRAuthDataResult *authResult, NSError *error) {
        _currentFirebaseUser = (id)authResult.user;
        self.refreshToken = authResult.user.refreshToken;
        
        [authResult.user getIDTokenWithCompletion:^(NSString *token, NSError *error) {
            if (token) {
                self.authToken = token;
            }
            completion(error);
        }];
    }];
}

- (void)loadCurrentUser:(YYErrorBlock)completion {
    [self refreshAuthToken:NO completion:completion];
}

- (void)refreshAuthToken:(BOOL)forceRefresh completion:(YYErrorBlock)completion {
    self.authToken = nil;
    _currentUser = nil;
    _currentFirebaseUser = nil;
    
    FIRUser *fbUser = FIRAuth.auth.currentUser;
    if (!fbUser) {
        return completion(self.notLoggedIn);
    }
    
    [fbUser getIDTokenResultForcingRefresh:forceRefresh completion:^(FIRAuthTokenResult *tokenResult, NSError *error) {
        if (tokenResult) {
            _currentFirebaseUser = fbUser;
            self.authToken = tokenResult.token;
            self.authTokenExpiry = tokenResult.expirationDate;
            [self updateUser:completion]; // I only do this bc we set _currentUser to nil, maybe we can skip both
        }
        else {
            NSParameterAssert(error);
            completion(error);
        }
    }];
}

- (void)updateUser:(nullable YYErrorBlock)completion {
    NSString *query = ({ @" \
        query Me { \
            me { \
                id \
                username \
                dateJoined \
                emoji \
                color \
                secondaryColor \
                yakarmaScore \
                completedTutorial \
                usersBlockedCount \
            } \
        } \
    "; });
    
    [self graphQL:query variables:@{} callback:^(TBResponseParser *parser) {
        NSString *path = @"data.me";
        
        [self completeWithClass:YYUser.self object:path response:parser completion:^(id object, NSError *error) {
            _currentUser = object;
            YYRunBlockP(completion, error);
            
            [NSNotificationCenter.defaultCenter postNotificationName:kYYDidUpdateUserNotification object:object];
        }];
    }];
}

- (void)guardLoggedIn:(void (^)())loggedInBlock loggedOut:(void (^)())loggedOutBlock {
    if (self.authToken) {
        // Did the auth token expire?
        if ([self.authTokenExpiry compare:NSDate.now] == NSOrderedDescending) {
            // Valid, continue
            loggedInBlock();
        }
        else {
            // It expired, reload it once
            [self refreshAuthToken:YES completion:^(NSError *error) {
                if (error) {
                    loggedOutBlock();
                } else {
                    loggedInBlock();
                }
            }];
        }
    } else {
        YYRunBlock(loggedOutBlock);
    }
}

#pragma mark Helper methods

- (void)completeWithResponse:(TBResponseParser *)parser completion:(YYErrorBlock)completion {
    if (completion) {
        NSError *error = [self tryDecodeAPIError:parser contextualPath:nil] ?: parser.error;
        completion(error);
    }
}

- (void)completeWithClass:(Class)cls object:(NSString *)keyPath response:(TBResponseParser *)parser completion:(YYResponseBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = [self tryDecodeAPIError:parser contextualPath:keyPath] ?: parser.error;
        NSDictionary *object = [parser.JSON valueForKeyPath:keyPath];
        id decodedObj = (error || isNull(object)) ? nil : [cls fromJSON:object];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(decodedObj, error);
        });
    });
}

- (void)completeWithClass:(Class)cls array:(NSString *)keyPath response:(TBResponseParser *)parser completion:(YYArrayBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = [self tryDecodeAPIError:parser contextualPath:keyPath] ?: parser.error;
        NSArray *objects = [parser.JSON valueForKeyPath:keyPath];
        id decodedObjs = (error || isNull(objects)) ? nil : [cls arrayOfModelsFromJSONArray:objects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(decodedObjs, error);
        });
    });
}

- (void)completeWithPaginatedClass:(Class)cls dataPath:(NSString *)keyPath
                          response:(TBResponseParser *)parser completion:(YYArrayPageBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = [self tryDecodeAPIError:parser contextualPath:keyPath] ?: parser.error;
        NSArray *objects = [parser.JSON valueForKeyPath:keyPath][@"edges"];
        NSDictionary *pageInfo = [parser.JSON valueForKeyPath:keyPath][@"pageInfo"];
        
        BOOL hasNext = [pageInfo[@"hasNextPage"] boolValue];
        NSString *cursor = hasNext ? pageInfo[@"endCursor"] : nil;
        
        // When a Yak is deleted, { data { yak { null } } } is returned
        id decodedObjs = (error || isNull(objects)) ? nil : [cls arrayOfModelsFromJSONArray:objects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Given cursor will be nil if there are no more pages
            completion(decodedObjs, cursor, error);
        });
    });
}

- (NSError *)tryDecodeAPIError:(TBResponseParser *)parser contextualPath:(NSString *)keyPath {
    // It is safe for these to be nil
    NSString *paginatedErrors = [keyPath stringByAppendingString:@".errors"];
    NSString *regularErrors = [keyPath.stringByDeletingPathExtension stringByAppendingString:@".errors"];
    
    NSArray *errors = parser.JSON[@"errors"] ?:
        [parser.JSON valueForKeyPath:regularErrors] ?:
        [parser.JSON valueForKeyPath:paginatedErrors];
    
    if (errors.count) {
        NSDictionary *error = errors.firstObject;
        // NSString *code = error[@"code"];
        return [TBResponseParser
            error:error[@"message"]
            domain:error[@"field"] ?: @"yakkit"
            code:parser.response.statusCode
        ];
    }
    
    return nil;
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

- (NSString *)graphQLLocation {
    CLLocationCoordinate2D location = self.location.coordinate;
    return [NSString stringWithFormat:@"POINT(%@ %@)", @(location.longitude), @(location.latitude)];
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
    return [TBResponseParser error:message domain:@"yakkit" code:code];
}

#pragma mark POST and GET

- (TBResponseBlock)makeAlwaysTryParseJSON:(TBResponseBlock)callback {
    return ^(TBResponseParser *parser) {
        parser.ignoreContentTypeForJSON = YES;
        callback(parser);
    };
}

- (TBURLRequestProxy *)request:(void(^)(TBURLRequestBuilder *))configurationHandler sign:(BOOL)sign {
    NSParameterAssert(self.authToken);
    
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
    [self guardLoggedIn:^{
        [self unsignedPost:^(TBURLRequestBuilder * _Nonnull make) {
            make.baseURL(kBaseAPIURL).endpoint(kepGraphQL).headers(self.graphQLHeaders);
            make.bodyJSON(@{ @"query": query, @"variables": variables });
        } callback:callback];
    } loggedOut:^{
        callback([TBResponseParser error:self.notLoggedIn]);
    }];
}

#pragma mark Firebase

- (void)setData:(NSDictionary *)data onDocument:(NSArray<NSString *> *)pathComponents completion:(YYErrorBlock)handler {
    if (self.notLoggedIn) { YYRunBlockP(handler, self.notLoggedIn); return; }
    
    NSString *documentPath = [pathComponents componentsJoinedByString:@"/"];
    FIRDocumentReference *document = [self.firestore documentWithPath:documentPath];
    [document setData:data completion:handler];
}

- (void)deleteDocumentData:(NSArray<NSString *> *)pathComponents completion:(YYErrorBlock)handler {
    if (self.notLoggedIn) { YYRunBlockP(handler, self.notLoggedIn); return; }
    
    NSString *documentPath = [pathComponents componentsJoinedByString:@"/"];
    FIRDocumentReference *document = [self.firestore documentWithPath:documentPath];
    [document deleteDocumentWithCompletion:handler];
}

@end
