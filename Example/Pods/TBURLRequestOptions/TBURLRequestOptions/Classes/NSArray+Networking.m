//
//  NSArray+Networking.m
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+Networking.h"


@implementation NSArray (Util)

- (NSString *)join:(NSString *)separator {
    NSMutableString *str = [NSMutableString string];
    for (NSString *part in self) {
        [str appendString:part];
        [str appendString:separator];
    }
    
    [str deleteCharactersInRange:NSMakeRange(str.length - separator.length, separator.length)];
    return str.copy;
}


@end

@implementation NSArray (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"[]";
}

@end