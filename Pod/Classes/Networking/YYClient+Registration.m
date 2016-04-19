//
//  YYClient+Registration.m
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYClient+Registration.h"


@implementation YYClient (Registration)

- (void)nicknamePolicy:(ResponseBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:kepGetNicknamePolicy_user, self.userIdentifier];
    [self get:URL(self.baseURLForRegion, endpoint) callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion([[YYNicknamePolicy alloc] initWithDictionary:json], nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)registerNewUser:(ErrorBlock)completion {
    [self get:URL(self.baseURLForRegion, kepRegisterUser) callback:^(id object, NSError *error) {
        completion(error);
    }];
}

- (void)checkHandleAvailability:(NSString *)handle completion:(BooleanBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:kepCheckHandle_user_handle, self.userIdentifier, handle];
    [self get:URL(self.baseURLForRegion, endpoint) callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion([json[@"code"] integerValue] == 2, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)startVerification:(NSString *)phoneNumber countryPrefix:(NSString *)prefix country:(NSString *)country completion:(StringBlock)completion {
    NSDictionary *params = @{@"country": country,
                             @"number": phoneNumber,
                             @"prefix": prefix,
                             @"type": @"sms"};
    [self postTo:URL(self.baseURLForRegion, kepStartVerification) params:params sign:NO callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion(json[@"token"], nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)endVerification:(NSString *)code token:(NSString *)token completion:(BooleanBlock)completion {
    NSDictionary *params = @{@"code": code,
                             @"token": token,
                             @"userID": self.userIdentifier};
    [self postTo:URL(self.baseURLForRegion, kepEndVerification) params:params sign:NO callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion([json[@"success"] isEqualToString:@"true"], nil);
        } else {
            completion(NO, error);
        }
    }];
}

@end


@implementation YYNicknamePolicy

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 0);
    NSError *error = nil;
    self = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"minDigits": @"minDigits",
             @"minAlpha": @"minAlpha",
             @"minLength": @"minLength",
             @"maxLength": @"maxLength",
             @"maxOther": @"maxOther"};
}

@end