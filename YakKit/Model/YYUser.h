//
//  YYUser.h
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYThing.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYUser : YYThing

@property (nonatomic, readonly, nullable) NSString  *handle;

@property (nonatomic, readonly) NSInteger karma;
@property (nonatomic, readonly) NSDate    *created;

@property (nonatomic, readonly) NSString *emoji;
@property (nonatomic, readonly) NSString *color;
@property (nonatomic, readonly) NSString *secondaryColor;
@property (nonatomic, readonly) BOOL completedTutorial;
@property (nonatomic, readonly) NSInteger usersBlockedCount;

@end

NS_ASSUME_NONNULL_END
