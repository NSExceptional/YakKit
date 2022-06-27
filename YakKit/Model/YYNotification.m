//
//  YYNotification.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYNotification.h"
#import "YYModel+Private.h"

YYThingType YYThingTypeFromString(NSString *type) {
    return [@{
        @"YAK":     @(YYThingTypeYak),
        @"COMMENT": @(YYThingTypeComment),
    }[type] integerValue];
}

NSString * YYStringFromThingType(YYThingType type) {
    switch (type) {
        case YYThingTypeComment:
            return @"comment";
        case YYThingTypeYak:
            return @"yak";
    }
    
    return nil;
}

YYNotificationReason YYNotificationReasonFromString(NSString *reason) {
    return [@{
        @"INFORMATIONAL":   @(YYNotificationReasonInfo),
        @"REMOVAL":         @(YYNotificationReasonRemoval),
        @"ALSO_INTERACTED": @(YYNotificationReasonInteraction),
        @"YOUR_YAK":        @(YYNotificationReasonYourYak),
    }[reason] integerValue];
}

NSString * YYStringFromNotificationReason(YYNotificationReason reason) {
    switch (reason) {
        case YYNotificationReasonInfo:
            return @"INFORMATIONAL";
        case YYNotificationReasonRemoval:
            return @"REMOVAL";
        case YYNotificationReasonInteraction:
            return @"ALSO_INTERACTED";
        case YYNotificationReasonYourYak:
        case YYNotificationReasonUpvotes:
            return @"YOUR_YAK";
    }
    
    return nil;
}

@implementation YYNotification
@synthesize thingIdentifier = _thingIdentifier;

+ (NSString *)selfJSONKeyPath { return @"node"; };

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        
        static NSCharacterSet *quotes = nil;
        if (!quotes) {
            quotes = [NSCharacterSet characterSetWithCharactersInString:@"'"];
        }
        
        switch (self.reason) {
            case YYNotificationReasonInfo:
                break;
            case YYNotificationReasonRemoval:
                if ([self.subject hasPrefix:@"A yak you posted was removed"]) {
                    _subject = @"Yak removed by your herd";
                }
                if ([self.subject hasPrefix:@"A comment you posted was removed"]) {
                    _subject = @"Comment removed by your herd";
                }
                if ([self.subject hasPrefix:@"Our automatic system removed a yak"]) {
                    _subject = @"Yak removed by auto moderation";
                }
                if ([self.subject hasPrefix:@"Our automatic system removed a comment"]) {
                    _subject = @"Comment removed by auto moderation";
                }
            case YYNotificationReasonInteraction:
                _subject = @"New activity on yak";
            case YYNotificationReasonYourYak: {
                NSString *newComment = @"New comment on your yak";
                // Strip comment from subject, add comment to content
                if ([self.subject hasPrefix:newComment]) {
                    _content = [_subject substringFromIndex:newComment.length];
                    _content = [_content stringByTrimmingCharactersInSet:quotes];
                    _subject = @"New comment";
                }
                else if ([self.subject containsString:@"Your yak was upvoted"]) {
                    // Skip the emojis
                    _subject = [self.subject substringFromIndex:4];
                    _reason = YYNotificationReasonUpvotes;
                }
            }
        }
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey { SetCoder(YYNotification)
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @codingKey(identifier): @"id",
        @codingKey(created): @"createdAt",
        @codingKey(read): @"isRead",
        @codingKey(subject): @"message",
        @codingKey(thingType): @"objectType",
        @codingKey(unencodedThingIdentifier): @"objectId",
        @codingKey(reason): @"notificationType",
    }];
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [self yy_stringDateTransformer];
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

- (NSString *)thingIdentifier {
    if (!_thingIdentifier) {
        // Identifiers are base64 encoded strings of the following payload format:
        // Type:identifier
        // Where 'Type' is 'Yak' or 'Comment' or something.
        // These identifiers are already encoded everywhere else by default. Not sure why they aren't encoded here.
        NSString *type = YYStringFromThingType(self.thingType).lowercaseString.capitalizedString;
        NSString *payload = [NSString stringWithFormat:@"%@:%@", type, self.unencodedThingIdentifier];
        NSData *bytes = [payload dataUsingEncoding:NSUTF8StringEncoding];
        _thingIdentifier = [bytes base64EncodedStringWithOptions:0];
    }
    
    return _thingIdentifier;
}

- (BOOL)unread { return !self.read; }

@end
