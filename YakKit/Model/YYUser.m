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
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @codingKey(identifier): @"id",
        @codingKey(handle): @"username",
        @codingKey(karma): @"yakarmaScore",
        @codingKey(created): @"dateJoined",
    }];
}

//- (NSString *)handle {
//    return self.identifier;
//}

+ (NSValueTransformer *)createdJSONTransformer { return [self yy_UTCDateTransformer]; }

@end
