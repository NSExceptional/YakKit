//
//  YYPersona.m
//  Pods
//
//  Created by Tanner on 7/28/16.
//
//

#import "YYPersona.h"


@implementation YYPersona

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"identifier": @"personaID",
              @"bio": @"bio",
              @"handle": @"nickname",
              @"yakarma": @"yakarma",
              @"hasPhoto": @"photoSet",
              @"socialMedia": @"externalProfiles",
              @"hasSocialMedia": @"hasExternalProfiles",
              @"hasBio": @"bioSet"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

@end
