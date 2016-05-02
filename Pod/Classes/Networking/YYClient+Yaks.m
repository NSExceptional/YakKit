//
//  YYClient+Yaks.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yaks.h"
#import "YYYak.h"
#import "YYComment.h"
#import "YYPeekLocation.h"
#import "YYNotification.h"
#import "NSDictionary+YakKit.h"


@implementation YYClient (Yaks)

#pragma mark Getting yak feeds

- (void)getLocalYaks:(ArrayBlock)completion {
    [self get:URL(self.baseURLForRegion, kepGetYaksAndLocations) callback:^(NSDictionary *object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

- (void)getLocalHotYaks:(ArrayBlock)completion {
    [self get:URL(self.baseURLForRegion, kepGetHotYaks) callback:^(NSDictionary *object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

- (void)getLocalTopYaks:(ArrayBlock)completion {
    [self get:URL(self.baseURLForRegion, kepGetAreaTopYaks) callback:^(NSDictionary *object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

- (void)getYaksInPeek:(YYPeekLocation *)location hot:(BOOL)hot completion:(ArrayBlock)completion {
    NSDictionary *params = [self generalParams:@{@"herdID": location.identifier, @"peekID": location.identifier}];
    if (hot) {
        params = [params dictionaryByReplacingValuesForKeys:@{@"hot": @"true"}];
    }
    
    [self get:kepGetPeekYaks params:params sign:YES callback:^(id object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

#pragma mark Getting info about a yak

- (void)getYak:(YYNotification *)notification completion:(ResponseBlock)completion {
    NSDictionary *params = [self generalParams:@{@"messageID": notification.thingIdentifier,
                                                 @"notificationType": YYStringFromNotificationReason(notification.reason)}];
    [self get:URL(self.baseURLForRegion, kepGetYakInfo) params:params sign:YES callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            completion([[YYYak alloc] initWithDictionary:[json[@"messages"] firstObject]], nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getCommentsForYak:(YYYak *)yak completion:(ArrayBlock)completion {
    [self get:URL(self.baseURLForRegion, kepGetComments) params:[self generalParams:@{@"messageID": yak.identifier}] sign:YES callback:^(id object, NSError *error) {
        [self completeWithClass:[YYComment class] jsonArray:object[@"comments"] error:error completion:completion];
    }];
}

@end
