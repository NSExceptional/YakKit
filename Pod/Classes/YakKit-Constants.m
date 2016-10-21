//
//  YakKit-Constants.m
//  Pods
//
//  Created by Tanner on 11/11/15.
//
//

#import "YakKit-Constants.h"


#pragma mark Notifications
NSString * const kYYDidUpdateUserNotification          = @"kYYDidUpdateUserNotification";
NSString * const kYYDidUpdateConfigurationNotification = @"kYYDidUpdateConfigurationNotification";
NSString * const kYYDidLoadNotificationsNotification   = @"kYYDidLoadNotificationsNotification";

#pragma mark Misc
NSString * const kUserAgent     = @"Yik Yak/4.3 (iPhone; iOS 9.3.3; Scale/2.00)";
NSString * const kYikYakVersion = @"4.3";

NSString * const kSignGETKey     = @"EF64523D2BD1FA21F18F5BC654DFC41B";
NSString * const kSignPOSTKey    = @"F7CAFA2F-FE67-4E03-A090-AC7FFF010729";
NSString * const kRequestSignKey = @"F7CAFA2F-FE67-4E03-A090-AC7FFF010729";

#pragma mark Base URLs
NSString * const kBaseNotifyURL             = @"https://notify.yikyakapi.net";
NSString * const kBaseContentURL            = @"https://content.yikyakapi.net";
NSString * const kBaseProfilesURL           = @"https://omega.yikyakapi.net";
NSString * const kBaseFeedURL               = @"https://omega.yikyakapi.net";
NSString * const kRegionUSEast              = @"us-east-api";
NSString * const kRegionUSCentral           = @"us-central-api";
NSString * const kUploadPhotoURL            = @"https://signedup.yikyakapi.net/upload";
NSString * const kAuthForWebURL             = @"https://www.yikyak.com/api/auth/initPairing";
// Must not have a trailing / or it will screw up one of my macros
NSString * const kHostRegexPattern          = @"https?://((?:[\\w-]+.)?[\\w-]+.\\w{2,3})";

#pragma mark Getting yaks, comments
NSString * const kepGetYaksAndLocations     = @"/api/getMessages";
NSString * const kepGetYakInfo              = @"/api/getMessage";
NSString * const kepGetHotYaks              = @"/api/hot";
NSString * const kepGetPeekYaks             = @"/api/getPeekMessages";
NSString * const kepGetAreaTopYaks          = @"/api/getAreaTops";
NSString * const kepGetComments             = @"/api/getComments";

#pragma mark Getting user data
NSString * const kepGetNotifications_user   = @"/api/getAllForUser/%@";
NSString * const kepGetUserData_user        = @"/v1/user/%@";
NSString * const kepGetNicknamePolicy_user  = @"/v1/user/%@/nicknamepolicy";
NSString * const kepHandle_user_handle      = @"/v1/user/%@/nickname/%@";
NSString * const kepGetMyRecentYaks         = @"/api/getMyRecentYaks";
NSString * const kepGetMyRecentReplies      = @"/api/getMyRecentReplies";
NSString * const kepGetMyTopYaks            = @"/api/getMyTops";

#pragma mark Modifying yaks and comments
NSString * const kepPostYak                 = @"/api/sendMessage";
NSString * const kepDeleteYak               = @"/api/deleteMessage2";
NSString * const kepPostComment             = @"/api/postComment";
NSString * const kepDeleteComment           = @"/api/deleteComment";

#pragma mark Voting
NSString * const kepToggleUpvoteYak         = @"/api/likeMessage";
NSString * const kepToggleDownvoteYak       = @"/api/downvoteMessage";
NSString * const kepToggleUpvoteComment     = @"/api/likeComment";
NSString * const kepToggleDownvoteComment   = @"/api/downvoteComment";

#pragma mark Registration
NSString * const kepRegisterUser            = @"/api/registerUser";
NSString * const kepStartVerification       = @"/api/startVerification";
NSString * const kepEndVerification         = @"/api/verify";

#pragma mark Profiles
NSString * const kepProfile_persona          = @"/v1/user/profile/%@";
NSString * const kepProfileLayer_persona     = @"/v1/layer/profile/%@";
NSString * const kepProfileAvatar_persona    = @"/v1/user/photo/%@/0";
NSString * const kepProfileSetAvatar_persona = @"/v1/user/photo/%@";
NSString * const kepProfileUpdateBio_user    = @"/v1/user/profile/bio/%@";
NSString * const kepProfileUpdateSocial_user = @"/v1/user/profile/external/%@";

#pragma mark Misc
NSString * const kepLayerAuthentication     = @"/v1/layer/authenticate";
NSString * const kepLogEvent                = @"/api/logEvent";
NSString * const kepRefreshersLocate        = @"/refreshers/locate";
NSString * const kepUpdateConfiguration     = @"/configurations/locate";
NSString * const kepMarkNotificationsBatch  = @"/api/updateBatch";
NSString * const kepMarkNotification        = @"/api/updateStatus";
NSString * const kepContactUs               = @"/api/contactUs";
