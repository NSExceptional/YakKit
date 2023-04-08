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
- (void)getLocalYaksAfter:(nullable NSString *)lastYak
               completion:(YYArrayPageBlock)completion NS_SWIFT_NAME(objc_getLocalYaks(after:_:));

- (void)getLocalHotYaksAfter:(nullable NSString *)lastYak
                  completion:(YYArrayPageBlock)completion NS_SWIFT_NAME(objc_getLocalHotYaks(after:_:));

- (void)getLocalTopYaksAfter:(nullable NSString *)lastYak
                  completion:(YYArrayPageBlock)completion NS_SWIFT_NAME(objc_getLocalTopYaks(after:_:));


- (void)getFeed:(NSString *)type order:(NSString *)order
          limit:(NSInteger)limit after:(nullable NSString *)lastYak
       callback:(YYArrayPageBlock)completion;

#pragma mark Getting info about a yak
- (void)getCommentsForYak:(YYYak *)yak after:(nullable NSString *)lastCommentID
               completion:(YYArrayPageBlock)completion NS_SWIFT_NAME(objc_getComments(for:after:completion:));;
- (void)getYak:(YYNotification *)notification completion:(YYResponseBlock)completion NS_SWIFT_NAME(objc_getYak(from:completion:));

@end

NS_ASSUME_NONNULL_END
