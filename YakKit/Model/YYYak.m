//
//  YYYak.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYYak.h"
#import "YYModel+Private.h"

@implementation YYYak

+ (NSString *)selfJSONKeyPath { return @"node"; };

+ (NSDictionary *)JSONKeyPathsByPropertyKey { SetCoder(YYYak)
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @codingKey(replyCount): @"commentCount",
    }];
}

//MTLStringToNumberJSONTransformer(hideLocationPin)
//MTLStringToNumberJSONTransformer(type)
//MTLStringToNumberJSONTransformer(replyCount)

- (NSString *)handle {
    if (self.emoji) {
        return [NSString stringWithFormat:@"%@ %@ %@", self.emoji, self.color, self.colorSecondary];
    }
    
    return self.authorIdentifier;
}

- (NSString *)title {
    return self.text;
}

- (BOOL)isReadOnly {
    return NO;
}

@end
