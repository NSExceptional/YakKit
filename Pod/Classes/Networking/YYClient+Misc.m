//
//  YYClient+Misc.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Misc.h"

@implementation YYClient (Misc)

- (void)logEvent:(NSString *)event completion:(nullable ErrorBlock)completion {
    NSParameterAssert(event);
    
    NSDictionary *query = @{@"eventType": event,
                            @"userID": self.userIdentifier};
    [self postTo:URL(self.baseURLForRegion, kepLogEvent) params:[self generalParams:nil] httpBodyParams:query sign:YES callback:^(NSDictionary *json, NSError *error) {
        [self handleStatus:json callback:completion];
    }];
}

- (void)refreshLocate:(nullable ErrorBlock)completion {
    NSDictionary *params = @{@"latitude": @(self.location.coordinate.longitude),
                             @"longitude": @(self.location.coordinate.latitude)};
    [self get:URL(kBaseContentURL, kepRefreshersLocate) params:params sign:NO callback:^(id object, NSError *error) {
        YYRunBlockP(completion, error);
    }];
}

- (void)contactUs:(NSString *)category message:(NSString *)message email:(NSString *)email completion:(nullable ErrorBlock)completion {
    NSParameterAssert(category); NSParameterAssert(message); NSParameterAssert(email);
    
    NSDictionary *query = @{@"category": category,
                            @"email": email,
                            @"message": message,
                            @"logs": [NSUUID UUID].UUIDString, // TODO idk what goes here, so
                            @"userID": self.userIdentifier};
    [self postTo:URL(self.baseURLForRegion, kepContactUs) params:[self generalParams:nil] httpBodyParams:query sign:YES callback:^(id object, NSError *error) {
        YYRunBlockP(completion, error);
    }];
}

@end
