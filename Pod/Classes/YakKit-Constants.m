//
//  YakKit-Constants.m
//  Pods
//
//  Created by Tanner on 11/11/15.
//
//

#import "YakKit-Constants.h"


NSString * const kUserAgent     = @"Yik Yak/2.10.3 (iPhone; iOS 9.0.2; Scale/2.00)";
NSString * const kYikYakVersion = @"2.10.3";

NSString * const kSignGETKey     = @"EF64523D2BD1FA21F18F5BC654DFC41B";
NSString * const kSignPOSTKey    = @"F7CAFA2F-FE67-4E03-A090-AC7FFF010729";
NSString * const kRequestSignKey = @"F7CAFA2F-FE67-4E03-A090-AC7FFF010729";

NSString * const kBaseNotify              = @"https://notify.yikyakapi.net/api/";
NSString * const kBaseContent             = @"https://content.yikyakapi.net/api/";
NSString * const kRegionUSEast            = @"us-east-api";
NSString * const kRegionUSCentral         = @"us-central-api";

NSString * const kepGetYaksAndLocations   = @"getMessages";
NSString * const kepGetHotYaks            = @"hot";
NSString * const kepGetPeekYaks           = @"getPeekMessages";
NSString * const kepGetAreaTopYaks        = @"getAreaTops";
NSString * const kepGetComments           = @"getComments";
NSString * const kepGetNotifications      = @"getAllForUser/";

NSString * const kepGetMyRecentYaks       = @"getMyRecentYaks";
NSString * const kepGetMyRecentReplies    = @"getMyRecentReplies";
NSString * const kepGetMyTopYaks          = @"getMyTops";

NSString * const kepPostYak               = @"sendMessage";
NSString * const kepDeleteYak             = @"deleteMessage";
NSString * const kepPostComment           = @"postComment";
NSString * const kepDeleteComment         = @"deleteComment";

NSString * const kepToggleUpvoteYak       = @"likeMessage";
NSString * const kepToggleDownvoteYak     = @"downvoteMessage";
NSString * const kepToggleUpvoteComment   = @"likeComment";
NSString * const kepToggleDownvoteComment = @"downvoteComment";

NSString * const kepLogEvent              = @"logEvent";
NSString * const kepRefreshersLocate      = @"refreshers/locate";
NSString * const kepMarkNotifications     = @"updateBatch";
NSString * const kepUpdateConfiguration   = @"configurations/locate";
