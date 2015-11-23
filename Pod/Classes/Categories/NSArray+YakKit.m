//
//  NSArray+YakKit.m
//  YaktKit
//
//  Created by Tanner on 11/12/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+YakKit.h"

@implementation NSArray (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"[]";
}

@end

@implementation NSArray (REST)

- (NSString *)recipientsString {
    if (!self.count) return @"[]";
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"["];
    
    for (NSString *recipient in self)
        [string appendFormat:@"\"%@\",", recipient];
    
    [string deleteCharactersInRange:NSMakeRange(string.length-1, 1)];
    [string appendString:@"]"];
    
    return string;
}

@end