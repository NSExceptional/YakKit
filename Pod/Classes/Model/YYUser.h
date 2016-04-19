//
//  YYUser.h
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYThing.h"


@interface YYUser : YYThing

@property (nonatomic, readonly) NSInteger karma;
@property (nonatomic, readonly) NSString  *handle;
@property (nonatomic, readonly) NSDate    *created;
@property (nonatomic, readonly) BOOL      isVerified;

@property (nonatomic, readonly) BOOL forceVerification;
@property (nonatomic, readonly) NSDictionary *basecamp;

@end
