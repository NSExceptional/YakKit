//
//  YYClient+Misc.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Misc.h"


@implementation YYClient (Misc)

- (void)logEvent:(NSString *)event completion:(nullable YYErrorBlock)completion {
    NSParameterAssert(event);
    
    NSDictionary *body = @{@"eventType": event,
                           @"userID": self.userIdentifier};
    
    [self post:^(TBURLRequestBuilder *make) {
        make.endpoint(kepLogEvent).bodyJSONFormString(body);
    } callback:^(TBResponseParser *parser) {
        [self handleStatus:parser.JSON callback:completion];
    }];
}

- (void)refreshLocate:(nullable YYErrorBlock)completion {
    NSDictionary *params = @{@"latitude": @(self.location.coordinate.longitude),
                             @"longitude": @(self.location.coordinate.latitude)};
    
    [self unsignedGet:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseContentURL).endpoint(kepRefreshersLocate).queries([self generalQuery:params]);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

- (void)contactUs:(NSString *)category message:(NSString *)message email:(NSString *)email completion:(nullable YYErrorBlock)completion {
    NSParameterAssert(category); NSParameterAssert(message); NSParameterAssert(email);
    
    NSDictionary *query = @{@"category": category,
                            @"email": email,
                            @"message": message,
                            @"logs": [NSUUID UUID].UUIDString, // TODO idk what goes here, so
                            @"userID": self.userIdentifier};
    
    [self post:^(TBURLRequestBuilder *make) {
        make.endpoint(kepContactUs).bodyJSONFormString(query);
    } callback:^(TBResponseParser *parser) {
        YYRunBlockP(completion, parser.error);
    }];
}

- (void)authenticateForLayer:(NSString *)nonce completion:(YYStringBlock)completion {
    // This endpoint takes JSON
    [self post:^(TBURLRequestBuilder *make) {
        make.endpoint(kepLayerAuthentication).bodyJSON(@{@"userID": self.userIdentifier, @"nonce": nonce});
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : parser.JSON[@"identity_token"], parser.error);
    }];
}

@end
