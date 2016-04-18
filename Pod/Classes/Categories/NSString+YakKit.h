//
//  NSString+YakKit.h
//  YakKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

- (NSData *)base64DecodedData;
- (NSString *)base64Encode;
- (NSString *)base64Decode;
- (NSString *)sha256Hash;
- (NSData *)sha256HashRaw;

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key;
+ (NSData *)hashHMacSHA1:(NSString *)data key:(NSString *)key;

- (NSString *)MD5Hash;

@end


@interface NSString (REST)
@property (nonatomic, readonly) NSString *URLEncodedString;
+ (NSString *)timestamp;
+ (NSString *)timestampFrom:(NSDate *)date;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;
+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues;
- (NSURL *)URLByAppendingQueryStringWithParams:(NSDictionary *)params;

@end


@interface NSString (Regex)
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)textFromHTML;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
@end

extern NSString * YYUniqueIdentifier();