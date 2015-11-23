//
//  NSDictionary+YakKit.m
//  YaktKit
//
//  Created by Tanner on 11/12/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+YakKit.h"
#import "NSString+YakKit.h"
#import "NSData+YakKit.h"
#import "YakKit-Constants.h"

@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
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
    for (NSString *key in dictionary.allKeys)
        m[key] = dictionary[key];
    
    return m;
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

@end


@implementation NSDictionary (RequestSigning)

- (void)signRequest:(NSString *)url hash:(NSString *__autoreleasing *)hash salt:(NSString *__autoreleasing *)salt {
    *salt = [NSString timestamp];
    
    // Trim string "htps://foo.bar/api/crap" to "/api/crap"
    NSMutableString *string = url.mutableCopy;
    NSRange r = [url rangeOfString:@"/api/"];
    r.length = r.location;
    r.location = 0;
    [string deleteCharactersInRange:r];
    
    if (self.allKeys.count) {
        [string appendString:@"?"];
        [string appendString:[NSString queryStringWithParams:self]];
    }
    
    [string appendString:*salt];
    NSString *hmac = [NSString hashHMacSHA1:string key:kSignGETKey].stringValueBase64;
    *hash = hmac;
}

- (NSDictionary *)dictionaryAfterSigningRequest:(NSString *)endpoint {
    NSString *hash, *salt;
    [self signRequest:endpoint hash:&hash salt:&salt];
    return [self dictionaryByReplacingKeysWithNewKeys:@{@"hash": hash, @"salt": salt}];
}

@end