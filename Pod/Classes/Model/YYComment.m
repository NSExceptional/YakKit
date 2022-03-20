//
//  YYComment.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYComment.h"


@implementation YYComment

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _isOP = [self.yakkerUID isEqualToString:self.relevantAuthorIdentifier];
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{
        @"body": @"text",
        @"relevantAuthorIdentifier": @"commenterUID",
        @"yakIdentifier": @"yakID",
    } mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

+ (NSValueTransformer *)isOPJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        return @([value isEqualToString:@"OP"]);
    }];
}

@end
