//
//  YYUser.m
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYUser.h"


@implementation YYUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"karma": @"yakarma",
             @"handle": @"nickname",
             @"created": @"created",
             @"isVerified": @"isVerified",
             @"isSuspended": @"IsSuspended",
             @"forceVerification": @"forceVerification",
             @"basecamp": @"basecamp",
             @"identifier": @"id"};
}

+ (NSValueTransformer *)createdJSONTransformer { return [self yy_UTCDateTransformer]; }

@end
