//
//  NSArray+Networking.h
//  TBURLRequestOptions
//
//  Created by Tanner Bennett on 1/7/16.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Util)
/// Joins other strings into a single string with the separator in between each.
- (NSString *)join:(NSString *)separator;
@end

@interface NSArray (JSON)
/// Will never return nil.
@property (nonatomic, readonly) NSString *JSONString;

@end
