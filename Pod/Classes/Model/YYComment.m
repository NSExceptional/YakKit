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
        if (self.personaIdentifier) {
            _relevantAuthorIdentifier = self.personaIdentifier;
        } else {
            // TODO does yik yak give same backID and overlayID to same commentor with and without handle?
            _relevantAuthorIdentifier = [self.backgroundIdentifier stringByAppendingString:self.overlayIdentifier];
        }
        
        if (!_textStyle.length) {
            _textStyle = nil;
        }
        
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
