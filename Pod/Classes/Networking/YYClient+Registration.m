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
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? [[YYNicknamePolicy alloc] initWithDictionary:parser.JSON] : nil, parser.error);
    }];
}

- (void)registerNewUser:(ErrorBlock)completion {
    [self get:^(TBURLRequestBuilder *make) {
        make.endpoint(kepRegisterUser);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)checkHandleAvailability:(NSString *)handle completion:(BooleanBlock)completion {
    [self handle:handle set:NO completion:completion];
}

- (void)setHandle:(NSString *)handle completion:(BooleanBlock)completion {
    [self handle:handle set:YES completion:completion];
}

- (void)handle:(NSString *)handle set:(BOOL)set completion:(BooleanBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:kepHandle_user_handle, self.userIdentifier, handle];
    id make = ^(TBURLRequestBuilder *make) {
        make.endpoint(endpoint);
    }, callback = ^(TBResponseParser *parser) {
        completion(parser.error ? NO : [parser.JSON[@"code"] integerValue] == 0, parser.error);
    };
    
    if (set) {
        [self post:make callback:callback];
    } else {
        [self get:make callback:callback];
    }
}

- (void)startVerification:(NSString *)phoneNumber countryPrefix:(NSString *)prefix country:(NSString *)country completion:(StringBlock)completion {
    NSDictionary *params = @{@"country": country,
                             @"number": phoneNumber,
                             @"prefix": prefix,
                             @"type": @"sms"};
    
    [self unsignedPost:^(TBURLRequestBuilder *make) {
        make.endpoint(kepStartVerification).queries(params);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : parser.JSON[@"token"], parser.error);
    }];
}

- (void)endVerification:(NSString *)code token:(NSString *)token completion:(BooleanBlock)completion {
    NSDictionary *params = @{@"code": code,
                             @"token": token,
                             @"userID": self.userIdentifier};
    
    [self unsignedPost:^(TBURLRequestBuilder *make) {
        make.endpoint(kepEndVerification).queries(params);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? NO : [parser.JSON[@"success"] isEqualToString:@"true"], parser.error);
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