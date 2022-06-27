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
- (void)getLocalYaks:(YYArrayBlock)completion NS_SWIFT_NAME(getLocalYaks_tuple(_:));
- (void)getLocalHotYaks:(YYArrayBlock)completion NS_SWIFT_NAME(getLocalHotYaks_tuple(_:));
- (void)getLocalTopYaks:(YYArrayBlock)completion NS_SWIFT_NAME(getLocalTopYaks_tuple(_:));

- (void)getFeed:(NSString *)type order:(NSString *)order
          limit:(NSInteger)limit after:(nullable NSString *)lastYak
       callback:(YYArrayBlock)completion;

#pragma mark Getting info about a yak
- (void)getCommentsForYak:(YYYak *)yak completion:(YYArrayBlock)completion;
- (void)getYak:(YYNotification *)notification completion:(YYResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
