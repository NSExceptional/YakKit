//
//  YakKit-Constants.h
//  Pods
//
//  Created by Tanner on 11/11/15.
//
//

#import <Foundation/Foundation.h>

typedef void (^RequestBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BooleanBlock)(BOOL success, NSError *error);
typedef void (^DataBlock)(NSData *data, NSError *error);
typedef void (^StringBlock)(NSString *string, NSError *error);
typedef void (^DictionaryBlock)(NSDictionary *dict, NSError *error);
typedef void (^ArrayBlock)(NSArray *collection, NSError *error);
typedef void (^CollectionResponseBlock)(NSArray *success, NSArray *failed, NSArray *errors);
typedef void (^ResponseBlock)(id object, NSError *error);
typedef void (^MiddleManBlock)(id object, NSError *error, NSURLResponse *response);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^VoidBlock)();


extern NSString * const kUserAgent;
extern NSString * const kYikYakVersion;

extern NSString * const kSignGETKey;
extern NSString * const kSignPOSTKey;


extern NSString * const kep;