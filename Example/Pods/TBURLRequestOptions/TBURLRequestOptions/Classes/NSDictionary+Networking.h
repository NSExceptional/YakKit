//
//  NSDictionary+Networking.h
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MergeDictionaries(a, b) [a dictionaryByReplacingValuesForKeys: b]

@interface NSDictionary (JSON)
@property (nonatomic, readonly) NSString *JSONString;
- (NSString *)JWTStringWithSecret:(NSString *)secret;
@end


@interface NSDictionary (REST)
/// @return An empty string if no parameters
@property (nonatomic, readonly) NSString *queryString;
/// @return An empty string if no parameters
@property (nonatomic, readonly) NSString *URLEscapedQueryString;
@end

@interface NSDictionary (Util)

@property (nonatomic, readonly) NSArray *allKeyPaths;

/// \c entryLimit must be greater than \c 0.
- (NSArray *)split:(NSUInteger)entryLimit;

- (NSDictionary *)dictionaryByReplacingValuesForKeys:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryByReplacingKeysWithNewKeys:(NSDictionary *)oldKeysToNewKeys;

@end
