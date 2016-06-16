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
        _relevantAuthorIdentifier = [self.backgroundIdentifier stringByAppendingString:self.overlayIdentifier];
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"body": @"comment",
              @"authorIdentifier": @"posterID",
              @"yakIdentifier": @"messageID",
              @"backgroundIdentifier": @"backID",
              @"overlayIdentifier": @"overlayID",
              @"textStyle": @"textStyle",
              @"identifier": @"commentID",
              @"isOP": @"textStyle"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

+ (NSValueTransformer *)isOPJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        return @([value isEqualToString:@"OP"]);
    }];
}

@end
