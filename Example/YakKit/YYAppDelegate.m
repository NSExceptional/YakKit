//
//  YYAppDelegate.m
//  YakKit
//
//  Created by ThePantsThief on 11/10/2015.
//  Copyright (c) 2015 ThePantsThief. All rights reserved.
//

#import "YYAppDelegate.h"
#import "YakKit.h"
#import "Login.h"
#import "TBTableViewController.h"
#import "MirrorKit.h"


@implementation YYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [YYClient sharedClient].region         = kRegionUSCentral;
    [YYClient sharedClient].userIdentifier = kYYUserID;
    [YYClient sharedClient].location       = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
    
    TBTableViewController *table = [TBTableViewController new];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.window.rootViewController = table;
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[YYClient sharedClient] getLocalHotYaks:^(NSArray *collection, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (!error) {
            collection = [collection valueForKeyPath:@"@unionOfObjects.title"];
            table.rowTitles = @[collection];
        } else {
            table.rowTitles = @[@[error.localizedDescription]];
        }
    }];
    
    return YES;
}

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end