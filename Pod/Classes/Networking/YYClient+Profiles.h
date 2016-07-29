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
- (void)profileForPersona:(NSString *)personaIdentifier completion:(ResponseBlock)completion;
- (void)layerIdentifierForPersona:(NSString *)personaIdentifier completion:(StringBlock)completion;
- (void)avatarForPersona:(NSString *)personaIdentifier completion:(DataBlock)completion;

#pragma mark Updating your own data
- (void)setProfileAvatar:(NSData *)imageData completion:(ErrorBlock)completion;
- (void)setProfileBio:(NSString *)bio completion:(ErrorBlock)completion;
/// Dictionary keys are NSNumbers containing YYSocialMediaType values
- (void)setUsernamesForSocialAccounts:(NSDictionary<NSNumber*,NSString*> *)socialToUser completion:(ErrorBlock)completion;

@end
