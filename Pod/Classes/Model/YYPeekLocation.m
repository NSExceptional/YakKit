//
//  YYPeekLocation.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYPeekLocation.h"

@implementation YYPeekLocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"canReply": @"canReply",
             @"canReport": @"canReport",
             @"canVote": @"canVote",
             @"delta": @"delta",
             @"isInactive": @"inactive",
             @"isFictional": @"isFictional",
             @"isLocal": @"isLocal",
             @"latitude": @"latitude",
             @"longitude": @"longitude",
             @"location": @"location",
             @"identifier": @"peekID"};
}

@end
