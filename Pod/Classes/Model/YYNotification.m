//
//  YYNotification.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYNotification.h"


YYThingType YYThingTypeFromString(NSString *type) {
    if ([type isEqualToString:@"comment"])
        return YYThingTypeComment;
    if ([type isEqualToString:@"yak"])
        return YYThingTypeYak;
    if ([type isEqualToString:@"info"])
        return YYThingTypeInfo;
    
    return 0;
}

NSString * YYStringFromThingType(YYThingType type) {
    switch (type) {
        case YYThingTypeComment:
            return @"comment";
        case YYThingTypeYak:
            return @"yak";
        case YYThingTypeInfo:
            return @"info";
    }
}

YYNotificationReason YYNotificationReasonFromString(NSString *reason) {
    if ([reason isEqualToString:@"comment"])
        return YYNotificationReasonComment;
    if ([reason isEqualToString:@"vote"])
        return YYNotificationReasonVote;
    if ([reason isEqualToString:@"handleRemoved"])
        return YYNotificationReasonHandleRemoved;
    
    return YYNotificationReasonUnspecified;
}

NSString * YYStringFromNotificationReason(YYNotificationReason reason) {
    switch (reason) {
        case YYNotificationReasonUnspecified:
            return nil;
        case YYNotificationReasonVote:
            return @"vote";
        case YYNotificationReasonComment:
            return @"comment";
        case YYNotificationReasonHandleRemoved:
            return @"handleRemoved";
    }
}


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
             @"thingType": @"thingType",
             @"__v": @"__v",
             @"updated": @"updated",
             @"userIdentifier": @"userID",
             @"identifier": @"_id",
             @"navigationURLString": @"navigationUrl",
             @"created": @"created",
             @"isNormalPriority": @"priority",
             @"reason": @"reason"};
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [NSDateFormatter new];
        sharedFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    });
    
    return sharedFormatter;
}

+ (NSValueTransformer *)dateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
        return [[self dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)updatedJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)unreadJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"unread": @YES, @"read": @NO} defaultValue:@NO reverseDefaultValue:@"unread"];
}

+ (NSValueTransformer *)isNormalPriorityJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return @([value isEqualToString:@"normal"]);
    }];
}

+ (NSValueTransformer *)thingTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return @(YYThingTypeFromString(value));
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError **error) {
        return YYStringFromThingType(value.integerValue);
    }];
}

+ (NSValueTransformer *)reasonJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return @(YYNotificationReasonFromString(value));
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError **error) {
        return YYStringFromNotificationReason(value.integerValue);
    }];
}

@end
