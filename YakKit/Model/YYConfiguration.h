//
//  YYConfiguration.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Mantle/Mantle.h>
@class YYThreatCheck;


@interface YYConfiguration : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

@property (nonatomic, readonly) NSString     *configHash;

@property (nonatomic, readonly) BOOL         identityCreationRequired;
@property (nonatomic, readonly) BOOL         identityUsageRequired;

@property (nonatomic, readonly) NSURL        *basecampURL;
@property (nonatomic, readonly) NSString     *endpointURLString;

@property (nonatomic, readonly) BOOL         draftsEnabled;
@property (nonatomic, readonly) BOOL         enableVoteChanging;
@property (nonatomic, readonly) NSInteger    yakarmaIncreaseValue;

@property (nonatomic, readonly) CGFloat      ratingRetryInterval;
@property (nonatomic, readonly) NSInteger    ratingThreshold;
@property (nonatomic, readonly) BOOL         shouldPromptForRating;

@property (nonatomic, readonly) NSString     *shareMessage;
@property (nonatomic, readonly) NSString     *shareTitle;
@property (nonatomic, readonly) NSInteger    famousThreshold;
@property (nonatomic, readonly) NSInteger    shareThreshold;
@property (nonatomic, readonly) NSDictionary *ratingThresholdDict;

@property (nonatomic, readonly) NSInteger voiceVerificationLevel;
@property (nonatomic, readonly) NSArray<NSDictionary *> *whitelistedCountriesForVoice;

@property (nonatomic, readonly) NSArray<YYThreatCheck *> *threatChecks;
@property (nonatomic, readonly) NSDictionary *googleAnalytics;


@property (nonatomic, readonly) NSString  *betaEndpointURLString;
@property (nonatomic, readonly) NSInteger betaMinimumThreshold;

@property (nonatomic, readonly) NSURL     *repApplicationURL;
@property (nonatomic, readonly) NSString  *repEntryText;
@property (nonatomic, readonly) NSInteger repYakarmaThreshold;

@end
