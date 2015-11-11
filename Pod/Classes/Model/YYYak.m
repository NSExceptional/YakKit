//
//  YYYak.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYYak.h"

@implementation YYYak

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"title": @"message",
              @"canUpvote": @"canUpvote",
              @"canDownvote": @"canDownvote",
              @"canReply": @"canReply",
              @"replyCount": @"comments",
              @"handle": @"handle",
              @"latitude": @"latitude",
              @"longitude": @"longitude",
              @"location": @"location",
              @"shouldShowLocationPin": @"locationDisplayStyle",
              @"locationName": @"locationName",
              @"authorIdentifier": @"posterID",
              @"isReadOnly": @"readOnly",
              @"isReyaked": @"reyaked",
              @"hasMedia": @"type",
              @"thumbnailURL": @"thumbnailUrl",
              @"mediaURL": @"url",
              @"type": @"type",
              @"identifier": @"messageID"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

+ (NSValueTransformer *)thumbnailURLTransformer { return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }
+ (NSValueTransformer *)mediaURLTransformer { return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }

- (BOOL)hasMedia {
    if (self.type == 6 && (!self.mediaURL || !self.thumbnailURL))
        [NSException raise:NSInternalInconsistencyException format:@"Yak media type is 6 but is missing media info"];
    return self.type == 6 && self.mediaURL && self.thumbnailURL;
}


@end
