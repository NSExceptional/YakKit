//
//  YYComment.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYComment.h"

@implementation YYComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"body": @"comment",
              @"authorIdentifier": @"posterID",
              @"yakIdentifier": @"messageID",
              @"backgroundIdentifier": @"backID",
              @"overlayIdentifier": @"overlayID",
              @"textStyle": @"textStyle",
              @"identifier": @"commentID"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (BOOL)isOP {
    // return [self.backgroundIdentifier isEqualToString:@"000"] && [self.overlayIdentifier isEqualToString:@"000"];
    return [self.textStyle isEqualToString:@"OP"];
}

@end
