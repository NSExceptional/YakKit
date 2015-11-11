//
//  YYNotification.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYNotification.h"

@implementation YYNotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"unread": @"status",
             @"summary": @"body",
             @"content": @"content",
             @"subject": @"subject",
             @"replyIdentifier": @"replyId",
             @"count": @"count",
             @"key": @"key",
             @"hashKey": @"hash_key",
             @"priority": @"priority",
             @"thingIdentifier": @"thingID",
             @"__v": @"__v",
             @"updated": @"updated",
             @"userIdentifier": @"userID",
             @"identifier": @"_id"};
}

+ (NSValueTransformer *)unreadTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"unread": @YES, @"read": @NO} defaultValue:@NO reverseDefaultValue:@"unread"];
}

- (BOOL)isNormalPriority {
    return [self.priority isEqualToString:@"normal"];
}

@end
