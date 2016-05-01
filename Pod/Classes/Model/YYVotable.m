//
//  YYVotable.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"

@implementation YYVotable

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"score": @"numberOfLikes",
             @"voteStatus": @"liked",
             @"created": @"time",
             @"gmt": @"gmt",
             @"deliveryIdentifier": @"deliveryID"};
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [NSDateFormatter new];
        sharedFormatter.dateFormat = @"y-mm-dd HH:mm:ss";
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

+ (NSValueTransformer *)createdJSONTransformer { return [self yy_stringDateTransformer]; }
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
