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


@implementation YYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [YYClient sharedClient].region         = kRegionUSCentral;
    [YYClient sharedClient].userIdentifier = kYYUserID;
    [YYClient sharedClient].location       = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
    
    TBTableViewController *table = [TBTableViewController new];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.window.rootViewController = table;
    [self.window makeKeyAndVisible];
    
    [[YYClient sharedClient] postYak:@"test post" useHandle:0 completion:^(NSError *error) {
        NSLog(@"Posted: %@", error);
        
        if (!error)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshTable:table callback:^(NSArray *collection, NSError *error2) {
                NSLog(@"Refreshed... %@", error2.localizedDescription);
                
                if (!error2)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    YYYak *yak = collection.firstObject;
                    NSLog(@"Deleting: %@ : %@", yak.title, yak.identifier);
                    
                    [[YYClient sharedClient] deleteYakOrComment:yak completion:^(NSError *error3) {
                        NSLog(@"Deleted %@", error3.localizedDescription);
                        [self refreshTable:table callback:^(NSArray *collection, NSError *error4) {
                        }];
                    }];
                });
            }];
        });
    }];
    
    return YES;
}

- (void)refreshTable:(TBTableViewController *)table callback:(ArrayBlock)callback {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[YYClient sharedClient] getLocalYaks:^(NSArray *collection, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        callback(collection, nil);
        
        if (!error) {
            collection = [collection valueForKeyPath:@"@unionOfObjects.title"];
            table.rowTitles = @[collection];
        } else {
            table.rowTitles = @[@[error.localizedDescription]];
        }
    }];
}

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end