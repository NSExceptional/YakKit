//
//  YYClient+Profiles.m
//  Pods
//
//  Created by Tanner on 7/28/16.
//
//

#import "YYClient+Profiles.h"
#import "NSData+Networking.h"
#import "NSArray+Networking.h"


NSString * YYStringFromSocialMediaType(YYSocialMediaType type) {
    switch (type) {
        case YYSocialMediaTypeSnapchat:
            return @"Snapchat";
        case YYSocialMediaTypeInstagram:
            return @"Instagram";
        case YYSocialMediaTypeTwitter:
            return @"Twitter";
        case YYSocialMediaTypeTumblr:
            return @"Tumblr";
        case YYSocialMediaTypePinterest:
            return @"Pinterest";
        case YYSocialMediaTypeFacebook:
            return @"Facebook";
        case YYSocialMediaTypeLinkedIn:
            return @"LinkedIn";
    }
}

@implementation YYClient (Profiles)

#pragma mark Getting other users' data

- (void)profileForPersona:(NSString *)personaIdentifier completion:(ResponseBlock)completion {
    [self get:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfile_persona, personaIdentifier]);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : parser.JSON, parser.error);
    }];
}

- (void)layerIdentifierForPersona:(NSString *)personaIdentifier completion:(StringBlock)completion {
    [self get:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfileLayer_persona, personaIdentifier]);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : parser.JSON[@"layerID"], parser.error);
    }];
}

- (void)avatarForPersona:(NSString *)personaIdentifier completion:(DataBlock)completion {
    [self get:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfileAvatar_persona, personaIdentifier]);
    } callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : parser.data, parser.error);
    }];
}

#pragma mark Updating your own data

- (void)setProfileAvatar:(NSData *)imageData completion:(ErrorBlock)completion {
    NSString *contentType = imageData.contentType ?: TBContentType.PNG;
    NSDictionary *query = @{@"userLat": @(self.location.coordinate.latitude),
                            @"userLong": @(self.location.coordinate.longitude),
                            @"userID": self.userIdentifier,
                            @"yakarma": @500};
    
    [self unsignedPost:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfileSetAvatar_persona, self.userIdentifier]);
        make.queries(query).body(imageData);
        make.headers(@{TBHeader.contentType: contentType, TBHeader.contentLength: @(imageData.length)});
    } callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)setProfileBio:(NSString *)bio completion:(ErrorBlock)completion {
    [self post:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfileUpdateBio_user, self.userIdentifier]);
        make.bodyJSON(@{@"yakarma": @500, @"bio": bio}); //TODO
    } callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)setUsernamesForSocialAccounts:(NSDictionary<NSNumber*,NSString*> *)socialToUser completion:(ErrorBlock)completion {
    NSMutableArray *externalProfiles = [NSMutableArray array];
    [socialToUser enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *account, BOOL *stop) {
        [externalProfiles addObject:@{@"network": @1, @"key": YYStringFromSocialMediaType(key.integerValue), @"account": account}];
    }];
    
    [self post:^(TBURLRequestBuilder *make) {
        make.baseURL(kBaseProfilesURL).endpoint([NSString stringWithFormat:kepProfileUpdateSocial_user, self.userIdentifier]);
        make.bodyJSON(@{@"yakarma": @500, @"externalProfiles": externalProfiles.JSONString});
    } callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

@end








