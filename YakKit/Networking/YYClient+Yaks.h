//
//  YYClient+Yaks.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Yaks)

#pragma mark Getting yak feeds
- (void)getLocalYaks:(YYArrayBlock)completion;
- (void)getLocalHotYaks:(YYArrayBlock)completion;
- (void)getLocalTopYaks:(YYArrayBlock)completion;

- (void)getFeed:(NSString *)type order:(NSString *)order
          limit:(NSInteger)limit after:(nullable NSString *)lastYak
       callback:(YYArrayBlock)completion;

#pragma mark Getting info about a yak
- (void)getYak:(YYNotification *)notification completion:(YYResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
