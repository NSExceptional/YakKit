//
//  NSDictionary+Networking.m
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+Networking.h"
#import "NSString+Networking.h"
#import "NSData+Networking.h"
#import "NSArray+Networking.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

- (NSString *)JWTStringWithSecret:(NSString *)key {
    NSString *header = @"{\"typ\":\"JWT\",\"alg\":\"HS256\"}";
    NSString *payload = [self.JSONString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSString *data = [@[header.base64URLEncoded, payload.base64URLEncoded] join:@"."];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, key.UTF8String, strlen(key.UTF8String), data.UTF8String, strlen(data.UTF8String), cHMAC);
    NSData *signature = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [@[data, signature.base64URLEncodedString] join:@"."];
}

@end


@implementation NSDictionary (REST)

- (NSString *)queryString {
    return [self queryStringURLEscapeValues:NO];
}

- (NSString *)URLEscapedQueryString {
    return [self queryStringURLEscapeValues:YES];
}

- (NSString *)queryStringURLEscapeValues:(BOOL)escapeValues {
    if (self.allKeys.count == 0) return @"";
    
    NSMutableString *q = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value isKindOfClass:[NSString class]]) {
            if (value.length) {
                if (escapeValues) {
                    value = [value URLEncodedString];
                } else {
                    value = [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                }
                // Only append if len > 1
                [q appendFormat:@"%@=%@&", key, value];
            }
        } else {
            // Append if NSNumber or something
            [q appendFormat:@"%@=%@&", key, value];
        }
    }];
    
    [q deleteCharactersInRange:NSMakeRange(q.length-1, 1)];
    
    return q;
}

@end


@implementation NSDictionary (Util)

- (NSArray *)split:(NSUInteger)entryLimit {
    NSParameterAssert(entryLimit > 0);
    if (self.allKeys.count <= entryLimit)
        return @[self];
    
    NSMutableArray *dicts = [NSMutableArray array];
    __block NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        tmp[key] = obj;
        if (tmp.allKeys.count % entryLimit == 0) {
            [dicts addObject:tmp];
            tmp = [NSMutableDictionary dictionary];
        }
    }];
    
    return dicts;
}

- (NSDictionary *)dictionaryByReplacingValuesForKeys:(NSDictionary *)dictionary {
    if (!dictionary || !dictionary.allKeys.count || !self) return self;
    
    NSMutableDictionary *m = self.mutableCopy;
    [m setValuesForKeysWithDictionary:dictionary];
    return m.copy;
}

- (NSDictionary *)dictionaryByReplacingKeysWithNewKeys:(NSDictionary *)oldKeysToNewKeys {
    if (!oldKeysToNewKeys || !oldKeysToNewKeys.allKeys.count || !self) return self;
    
    NSMutableDictionary *m = self.mutableCopy;
    [oldKeysToNewKeys enumerateKeysAndObjectsUsingBlock:^(NSString *oldKey, NSString *newKey, BOOL *stop) {
        id val = m[oldKey];
        m[oldKey] = nil;
        m[newKey] = val;
    }];
    
    return m;
}

- (NSArray *)allKeyPaths {
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [keyPaths addObject:key];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            for (NSString *kp in [obj allKeyPaths])
                [keyPaths addObject:[NSString stringWithFormat:@"%@.%@", key, kp]];
        }
    }];
    
    return keyPaths.copy;
}

@end
