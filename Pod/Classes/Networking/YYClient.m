//
//  YYClient.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYClient.h"

@implementation YYClient

+ (instancetype)sharedClient {
    static YYClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    
    return sharedClient;
}

@end
