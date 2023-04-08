//
//  YYComment.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYComment.h"
#import "YYModel+Private.h"

@implementation YYComment

//- (id)initWithDictionary:(NSDictionary *)json {
//    self = [super initWithDictionary:json];
//    if (self) {
//        _isOP = [self.authorIdentifier isEqualToString:self.yakkerIdentifier];
//    }
//    
//    return self;
//}

+ (NSString *)selfJSONKeyPath { return @"node"; };

+ (NSDictionary *)JSONKeyPathsByPropertyKey { SetCoder(YYComment)
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @codingKey(isOP): @"isOp",
        @codingKey(yakIdentifier): @"yak.id",
    }];
}

//+ (NSValueTransformer *)isOPJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
//        return @([value isEqualToString:@"OP"]);
//    }];
//}

- (NSString *)commentID {
    return self.identifier;
}

- (NSString *)relevantAuthorIdentifier {
    return self.authorIdentifier;
}

- (NSString *)body {
    return self.text;
}

@end
