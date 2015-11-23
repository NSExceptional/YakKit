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

+ (NSValueTransformer *)yy_UTCDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *ts, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:ts.doubleValue/1000.f];
    } reverseBlock:^id(NSDate *ts, BOOL *success, NSError *__autoreleasing *error) {
        return @([ts timeIntervalSince1970] * 1000.f).stringValue;
    }];
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
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)createdTransformer { return [self yy_stringDateTransformer]; }
+ (NSValueTransformer *)gmtTransformer { return [self yy_stringDateTransformer]; }


@end
