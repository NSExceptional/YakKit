//
//  YYVotable.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"

@implementation YYVotable

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        if (self.created.timeIntervalSinceReferenceDate == 25261) {
            _created = self.gmt;
        }
        
        if (!_username.length) {
            _username = nil;
        }
        if (!_personaIdentifier.length) {
            _personaIdentifier = nil;
        }
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"score": @"numberOfLikes",
             @"voteStatus": @"liked",
             @"created": @"gmt", // "time" is deprecated
             @"gmt": @"gmt",
             @"username": @"nickname",
             @"deliveryIdentifier": @"deliveryID",
             @"personaIdentifier": @"personaID"};
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [NSDateFormatter new];
        sharedFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        sharedFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    });
    
    return sharedFormatter;
}

+ (NSValueTransformer *)yy_stringDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
        return [[self dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

MTLStringToNumberJSONTransformer(voteStatus)
+ (NSValueTransformer *)createdJSONTransformer { return [self gmtJSONTransformer]; }//yy_stringDateTransformer]; }
+ (NSValueTransformer *)gmtJSONTransformer { return [self yy_UTCDateTransformer]; }

//+ (NSValueTransformer *)deliveryIdentifierJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
//        if ([value isKindOfClass:[NSNumber class]]) {
//            return value.stringValue;
//        } else {
//            return value;
//        }
//    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
//        return value;
//    }];
//}

- (NSComparisonResult)compareScore:(YYVotable *)votable {
    if (self.score < votable.score) {
        return NSOrderedAscending;
    } else if (self.score == votable.score) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

- (NSComparisonResult)compareCreated:(YYVotable *)votable {
    return [self.created compare:votable.created];
}


@end
