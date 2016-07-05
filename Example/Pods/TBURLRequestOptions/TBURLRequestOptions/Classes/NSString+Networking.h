//
//  NSString+Encoding.h
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Encoding)

@property (nonatomic, readonly) NSString *base64Encoded;
@property (nonatomic, readonly) NSString *base64URLEncoded;
@property (nonatomic, readonly) NSString *base64Decoded;
@property (nonatomic, readonly) NSData   *base64DecodedData;

@property (nonatomic, readonly) NSString *MD5Hash;
@property (nonatomic, readonly) NSString *sha256Hash;
@property (nonatomic, readonly) NSData   *sha256HashData;

+ (NSData *)hashHMacSHA256:(NSString *)data key:(NSString *)key;
+ (NSString *)hashHMac256ToString:(NSString *)data key:(NSString *)key;
+ (NSData *)hashHMacSHA1:(NSString *)data key:(NSString *)key;

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
@property (nonatomic, readonly) NSString *textFromHTML;
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
@end
