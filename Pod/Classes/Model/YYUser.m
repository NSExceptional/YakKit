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
             @"IsSuspended": @"isSuspended",
             @"forceVerification": @"forceVerification",
             @"basecamp": @"basecamp",
             @"identifier": @"id"};
}

+ (NSValueTransformer *)createdJOSONTransformer { return [self yy_UTCDateTransformer]; }

@end
