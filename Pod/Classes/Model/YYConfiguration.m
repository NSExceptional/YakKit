//
//  YYConfiguration.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYConfiguration.h"
#import "YYThreatCheck.h"


@implementation YYConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"configHash": @"hash",
             @"basecampURL": @"configuration.basecamp.tutorialUrl",
             @"endpointURLString": @"configuration.endpointUrl",
             @"draftsEnabled": @"configuration.drafts.enabled",
             @"enableVoteChanging": @"configuration.voting.enableVoteChanging",
             @"yakarmaIncreaseValue": @"configuration.voting.yakarmaIncreaseValue",
             @"threatChecks": @"configuration.threatChecks",
             @"googleAnalytics": @"configuration.googleAnalytics",
             @"ratingRetryInterval": @"configuration.rating.ratingRetryInterval",
             @"ratingThreshold": @"configuration.rating.ratingThreshold",
             @"shouldPromptForRating": @"configuration.rating.shouldPromptForRating",
             @"shareTitle": @"configuration.shareThreshold.title",
             @"shareMessage": @"configuration.shareThreshold.message",
             @"famousThreshold": @"configuration.shareThreshold.famousThreshold",
             @"shareThreshold": @"configuration.shareThreshold.shareThreshold",
             @"ratingThresholdDict": @"configuration.ratingThreshold",
             @"voiceVerificationLevel": @"configuration.verification.voiceVerificationLevel",
             @"whitelistedCountriesForVoice": @"configuration.verification.whitelistedCountriesForVoice",
             @"betaEndpointURLString": @"configuration.webAuthentication.endpointUrl",
             @"betaMinimumThreshold": @"configuration.webAuthentication.minimumThreshold",
             @"repApplicationURL": @"configuration.yikYakRepApplicationConfiguration.applicationUrl",
             @"repEntryText": @"configuration.yikYakRepApplicationConfiguration.entryText",
             @"repYakarmaThreshold": @"configuration.yikYakRepApplicationConfiguration.yakarmaThreshold"};
}

+ (NSValueTransformer *)basecampURLTransformer { return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }
+ (NSValueTransformer *)repApplicationURLTransformer { return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }

+ (NSValueTransformer *)threatChecksTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *checks, BOOL *success, NSError **error) {
        NSMutableArray *threats = [NSMutableArray array];
        for (NSDictionary *json in checks)
            [threats addObject:[[YYThreatCheck alloc] initWithDictionary:json error:nil]];
        
        return threats.copy;
    } reverseBlock:^id(NSArray<YYThreatCheck *> *threats, BOOL *success, NSError **error) {
        return [threats valueForKeyPath:@"@unionOfObjects.dictionaryValue"];
    }];
}


@end
