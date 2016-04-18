//
//  YYClient+Yaks.m
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient+Yaks.h"
#import "YYYak.h"


@implementation YYClient (Yaks)

#pragma mark Helper methods

- (void)completeWithClass:(Class)cls jsonArray:(NSArray *)objects error:(NSError *)error completion:(ArrayBlock)completion {
    if (!error) {
        completion([[cls class] arrayOfModelsFromJSONArray:objects], nil);
    } else {
        completion(nil, error);
    }
}

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

- (void)getYaksInPeek:(YYPeekLocation *)location completion:(ArrayBlock)completion {
}

#pragma mark Getting comments

- (void)getCommentsForYak:(YYYak *)yak completion:(ArrayBlock)completion {
    
}

@end
