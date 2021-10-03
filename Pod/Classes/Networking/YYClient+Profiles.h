//
//  YYClient+Profiles.h
//  Pods
//
//  Created by Tanner on 7/28/16.
//
//

#import "YYClient.h"


typedef NS_ENUM(NSUInteger, YYSocialMediaType)
{
    YYSocialMediaTypeSnapchat = 1,
    YYSocialMediaTypeInstagram,
    YYSocialMediaTypeTwitter,
    YYSocialMediaTypeTumblr,
    YYSocialMediaTypePinterest,
    YYSocialMediaTypeFacebook,
    YYSocialMediaTypeLinkedIn
};

@interface YYClient (Profiles)

#pragma mark Getting other users' data
- (void)profileForPersona:(NSString *)personaIdentifier completion:(YYResponseBlock)completion;
- (void)layerIdentifierForPersona:(NSString *)personaIdentifier completion:(YYStringBlock)completion;
- (void)avatarForPersona:(NSString *)personaIdentifier completion:(YYDataBlock)completion;

#pragma mark Updating your own data
- (void)setProfileAvatar:(NSData *)imageData completion:(YYErrorBlock)completion;
- (void)setProfileBio:(NSString *)bio completion:(YYErrorBlock)completion;
/// Dictionary keys are NSNumbers containing YYSocialMediaType values
- (void)setUsernamesForSocialAccounts:(NSDictionary<NSNumber*,NSString*> *)socialToUser completion:(YYErrorBlock)completion;

@end
