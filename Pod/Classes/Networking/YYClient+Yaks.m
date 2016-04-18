//
//  YYClient+Yaks.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yaks.h"
#import "YYYak.h"
#import "YYPeekLocation.h"
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

#pragma mark Getting comments

- (void)getCommentsForYak:(YYYak *)yak completion:(ArrayBlock)completion {
    [self get:kepGetComments params:[self generalParams:@{@"messageID": yak.identifier}] sign:YES callback:^(id object, NSError *error) {
        [self completeWithClass:[YYYak class] jsonArray:object[@"messages"] error:error completion:completion];
    }];
}

@end
