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

extern NSString * const kRequestSignKey;

extern NSString * const kBaseNotify;
extern NSString * const kBaseContent;
extern NSString * const kRegionUSEast;
extern NSString * const kRegionUSCentral;

extern NSString * const kepGetYaksAndLocations;
extern NSString * const kepGetHotYaks;
extern NSString * const kepGetPeekYaks;
extern NSString * const kepGetAreaTopYaks;
extern NSString * const kepGetComments;
extern NSString * const kepGetNotifications;

extern NSString * const kepGetMyRecentYaks;
extern NSString * const kepGetMyRecentReplies;
extern NSString * const kepGetMyTopYaks;

extern NSString * const kepPostYak;
extern NSString * const kepDeleteYak;
extern NSString * const kepPostComment;
extern NSString * const kepDeleteComment;

extern NSString * const kepToggleUpvoteYak;
extern NSString * const kepToggleDownvoteYak;
extern NSString * const kepToggleUpvoteComment;
extern NSString * const kepToggleDownvoteComment;

extern NSString * const kepLogEvent;
extern NSString * const kepRefreshersLocate;
extern NSString * const kepMarkNotifications;
extern NSString * const kepUpdateConfiguration;
