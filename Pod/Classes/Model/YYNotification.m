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

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [NSDateFormatter new];
        sharedFormatter.dateFormat = @"y-mm-ddTHH:mm:SZ";
    });
    
    return sharedFormatter;
}

+ (NSValueTransformer *)updatedTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)unreadTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"unread": @YES, @"read": @NO} defaultValue:@NO reverseDefaultValue:@"unread"];
}

- (BOOL)isNormalPriority {
    return [self.priority isEqualToString:@"normal"];
}

@end
