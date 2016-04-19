//
//  YakKit-Constants.h
//  Pods
//
//  Created by Tanner on 11/11/15.
//
//

#import <Foundation/Foundation.h>

#define YYRunBlock(block) if ( block ) block()
#define YYRunBlockP(block, ...) if ( block ) block( __VA_ARGS__ )

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

#pragma mark Base URLs
extern NSString * const kBaseNotifyURL;
extern NSString * const kBaseContentURL;
/// Use this with -[YYClient setRegion:]
extern NSString * const kRegionUSEast;
/// Use this with -[YYClient setRegion:]
extern NSString * const kRegionUSCentral;
extern NSString * const kUploadPhotoURL;
extern NSString * const kAuthForWebURL;
extern NSString * const kHostRegexPattern;

#pragma mark - Endpoints

#pragma mark Getting yaks, comments
extern NSString * const kepGetYaksAndLocations;
extern NSString * const kepGetYakInfo;
extern NSString * const kepGetHotYaks;
extern NSString * const kepGetPeekYaks;
extern NSString * const kepGetAreaTopYaks;
extern NSString * const kepGetComments;

#pragma mark Getting user data
/// Goes with kBaseNotify
extern NSString * const kepGetNotifications_user;
extern NSString * const kepGetUserData_user;
extern NSString * const kepGetNicknamePolicy_user;
extern NSString * const kepCheckHandle_user_handle;
extern NSString * const kepGetMyRecentYaks;
extern NSString * const kepGetMyRecentReplies;
extern NSString * const kepGetMyTopYaks;

#pragma mark Modifying yaks and comments
extern NSString * const kepPostYak;
extern NSString * const kepDeleteYak;
extern NSString * const kepPostComment;
extern NSString * const kepDeleteComment;

#pragma mark Voting
extern NSString * const kepToggleUpvoteYak;
extern NSString * const kepToggleDownvoteYak;
extern NSString * const kepToggleUpvoteComment;
extern NSString * const kepToggleDownvoteComment;

#pragma mark Registration
extern NSString * const kepRegisterUser;
extern NSString * const kepStartVerification;
extern NSString * const kepEndVerification;

#pragma mark Misc
extern NSString * const kepLogEvent;
/// Goes with kBaseContent
extern NSString * const kepRefreshersLocate;
/// Goes with kBaseContent
extern NSString * const kepUpdateConfiguration;
/// Goes with kBaseNotify
extern NSString * const kepMarkNotificationsBatch;
/// Goes with kBaseNotify
extern NSString * const kepMarkNotification;
extern NSString * const kepContactUs;
