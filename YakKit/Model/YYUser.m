//
//  YYUser.m
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYUser.h"
#import "YYModel+Private.h"

@implementation YYUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey { SetCoder(YYUser)
    return @{
        @codingKey(identifier): @"id",
        @codingKey(karma): @"yakarma",
        @codingKey(created): @"created",
        @codingKey(isVerified): @"isVerified",
        @codingKey(isSuspended): @"IsSuspended",
        @codingKey(forceVerification): @"forceVerification",
        @codingKey(basecamp): @"basecamp",
    };
}

- (NSString *)handle {
    return self.identifier;
}

+ (NSValueTransformer *)createdJSONTransformer { return [self yy_UTCDateTransformer]; }

@end
