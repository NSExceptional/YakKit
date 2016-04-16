//
//  YakKitTests.m
//  YakKitTests
//
//  Created by ThePantsThief on 11/10/2015.
//  Copyright (c) 2015 ThePantsThief. All rights reserved.
//

@import XCTest;
#import "YYClient.h"
#import "NSString+YakKit.h"


@interface Tests : XCTestCase
@end

@implementation Tests

- (void)testSignGET {
    NSString *signd = [[YYClient sharedClient] signRequest:@"/api/getMessages"
                                                    params:@{@"userID": @"CFFA424A-5281-4E06-9402-67EB3FB5E40F",
                                                             @"lat": @"31.545682",
                                                             @"long": @"-97.113371",
                                                             @"loc": @"false",
                                                             @"userLat": @"31.545682",
                                                             @"userLong": @"-97.113371",
                                                             @"version": @"3.3.1",
                                                             @"verticalAccuracy": @"0.000000",
                                                             @"horizontalAccuracy": @"0.000000",
                                                             @"altitude": @"0.000000",
                                                             @"floorLevel": @"0",
                                                             @"speed": @"0.000000",
                                                             @"course": @"0.000000"}];
    
    //    /api/hot?
    //    userID=CFFA424A-5281-4E06-9402-67EB3FB5E40F
    //    lat=31.545671
    //    long=-97.113405
    //    userLat=31.545671
    //    userLong=-97.113405
    //    version=3.3.1
    //    horizontalAccuracy=0.000000
    //    verticalAccuracy=0.000000
    //    altitude=0.000000
    //    floorLevel=0
    //    speed=0.000000
    //    course=0.000000
    //    1460796464
    NSLog(@"\n\nhttps://us-east-api.yikyakapi.net%@\n\n", signd);
}

- (void)testBasicHash {
    NSString *result = [[NSString hashHMacSHA1:@"/api/hot?userID=CFFA424A-5281-4E06-9402-67EB3FB5E40F&lat=31.545671&long=-97.113405&userLat=31.545671&userLong=-97.113405&version=3.3.1&horizontalAccuracy=0.000000&verticalAccuracy=0.000000&altitude=0.000000&floorLevel=0&speed=0.000000&course=0.0000001460796464" key:kRequestSignKey] base64EncodedStringWithOptions:0];
    XCTAssertEqualObjects(result, @"sDe1ohooRGlGlTC8nB/cYwPuyIY=");
}

@end

